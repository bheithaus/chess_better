# encoding: utf-8

require 'debugger'

class Board
	attr_reader :matrix

	def initialize
		@matrix = Array.new(8) { [nil]*8 }
	end

	def add_piece(piece)
		@matrix[piece.position] = piece
	end

	def [](position)
		x, y = position
		@matrix[x][y]
	end

	def []=(position, set_to)
		x, y = position
		@matrix[x][y] = set_to
	end

	def update_pawns(end_pos)
		# if mover is not a pawn
		#still need to write if mover is a pawn
		moving_piece = @matrix[end_pos]
		color = moving_piece.color

		if color == :white
			move1 = [1, 1]
			move2 = [1, -1]
		else
			move1 = [-1, -1]
			move2 = [-1, 1]
		end

		maybe_pawn_positions = [end_pos[0] + move1[0], end_pos[1] + move1[1]], [end_pos[0] + move2[0], end_pos[1] + move2[1]]
		maybe_pawn_positions.keep_if {|pos| in_bounds?(pos)}
		maybe_pawns = []
		maybe_pawn_positions.each { |pos| maybe_pawns << @matrix[pos] }
		maybe_pawns.each do |maybe_pawn|
				if maybe_pawn.class == WhitePawn || maybe_pawn.class == BlackPawn
					maybe_pawn.new_neighbor(moving_piece)
				end
		end
	end

	def piece_at(position)
		@matrix[position]
	end

	#test for in check and in bounds here, in the board
	#test for legal move in piece
	#test for not running self over in HumanPlayer
	def valid_move?(start_pos, end_pos, delta, player, enemy)
		return false unless in_bounds?(end_pos)
		return false unless free_path?(start_pos, end_pos, delta)
		move_piece(start_pos, end_pos)
		king_pos = player.pieces[:k].position
		valid = in_check?(king_pos, enemy) ? false : true
		move_piece(end_pos, start_pos)  #move back

		valid
	end

	def free_path?(start_pos, end_pos, delta)
		intermediate_pos = start_pos.dup
		end_pos = end_pos.dub
		end_pos[0] -= delta[0]
		end_pos[1] -= delta[1]
		until intermediate_pos[0] == end_pos[0] && intermediate_pos[1] == end_pos[1]
			intermediate_pos[0] += delta[0]
			intermediate_pos[1] += delta[1]
			return false if @matrix[intermediate_pos] != nil
		end

		true
	end

	#potentially check-making move has been made before this function is called
	#end_pos is king's position
	def in_check?(end_pos, enemy)

		enemy.pieces.each do |piece| #loop through all enemy pieces
			position = piece.position
			delta = piece.valid_move?(end_pos) #for each piece, return which move
			#delta would get you to the king, if any
			unless delta == nil
					return true if free_path?(position, end_pos, delta)
			end
		end
		false
	end

	def in_bounds?(position) #end_position
		position.all? { |x| x >= 0 && x <= 7 }
	end

	#after current player moves, sends in their enemy's king position and themself as "enemy"
	def check_mate?#(king_pos, victim, attacker)
		# if in_check?(king_pos, enemy)
	# 		victim.pieces.each do |piece|
	#
	#
	# 		end
		###test all the players peices
		##
		###   NEEDS ATTENTION
		##
		##
		##
		false
	end

	def move_piece(start_pos, end_pos)
		piece = @matrix[start_pos]
		remove_piece(start_pos)
		@matrix[end_pos] = piece
		update_pawns(end_pos)
	end

	def print_board
		printer = PrintClass.new()
		print_board = Array.new(8) { ["_"]*8 }
		@matrix.each_with_index do |row, i|
			row.each_with_index do |square, j|
				unless col == nil
					print_board[i,j] = square.render
				end
			end
		end

		print_board
	end

private

	def remove_piece(start_pos)
		removed_piece = @matrix[start_pos]
		color = removed_piece.color
		##check around removed piece corners
		## if the corners are in_bounds, and pawns remove this pawn neighbor

		if color == :white
			move1 = [1, 1]
			move2 = [1, -1]
		else
			move1 = [-1, -1]
			move2 = [-1, 1]
		end

		maybe_pawn_positions = [[i + move1[0], j + move1[1]],[ i + move2[0], j + move2[1]]]
		maybe_pawn_positions.keep_if { |pos| in_bounds?(pos) }
		maybe_pawns = []
		maybe_pawn_positions.each { |pos| maybe_pawns << @matrix[pos[0]][pos[1]] }
		maybe_pawns.each do |maybe_pawn|
				if maybe_pawn.class == WhitePawn || maybe_pawn.class == BlackPawn
					maybe_pawn.remove_neighbor(removed_piece)
				end
		end

		@matrix[i, j] = nil
		#remove pawn neighbor
	end
end

class Game
	attr_accessor :board, :player1, :player2

	def initialize

		@board = Board.new
		@player1 = Human_Player.new(:white, "Brian", @board)
		@player2 = Human_Player.new(:black, "April", @board)
		play
	end

	def play
		counter = 1
		until @board.check_mate?
			show
			if counter.odd?
				current_player = @player1
				enemy = @player2
			else
				current_player = @player2
				enemy = @player1
			end
			make_move(current_player, enemy)
			counter +=1
		end
		puts "Game Over: Check Mate! #{current_player.name} wins "


	end

	def make_move(player, enemy)
		#start_pos == [0,1]??
		#debugger
		start_pos, end_pos = player.get_move
		chosen_piece = @board.piece_at(start_pos)
		debugger
		puts "first piece #{chosen_piece}"
		delta = chosen_piece.valid_move?(end_pos)
		until delta && @board.valid_move?(start_pos, end_pos, delta, player, enemy)
			### enter here if user's first choice was invalid
			start_pos, end_pos = player.get_move
			chosen_piece = @board.piece_at(start_pos)
			delta = chosen_piece.valid_move?(end_pos)
		end

		@board.move_piece(start_pos, end_pos)
	end

	def show
	    puts "    0 1 2 3 4 5 6 7 8"
	    puts "    -----------------"
	    @board.print_board.each_with_index do |row, i|
	      print "#{i} | "
	      row.each do |square|
	        print "#{square} "
	      end
	      puts
	    end
	  end

end


class Human_Player
	attr_reader :name, :pieces

	def initialize(color, board, name = "blank")
		@name = name
		@color = color
		@board = board
		make_team
	end

	def make_team
		@pieces = {}


		if @color == :white
			row = 0
			# set king and queen
			@pieces[:q] = Queen.new(@color, @board, [row, 4])
			@pieces[:k] = King.new(@color, @board, [row, 3])
		else
			row = 7
			@pieces[:q] = Queen.new(@color, @board, [row, 3])
			@pieces[:k] = King.new(@color, @board, [row, 4])
		end

		@pieces[:r1] = Rook.new(@color, @board, [row, 0])
		@pieces[:r2] = Rook.new(@color, @board, [row, 7])
		@pieces[:b1] = Bishop.new(@color, @board, [row, 2])
		@pieces[:b2] = Bishop.new(@color, @board, [row, 5])
		@pieces[:n1] = Knight.new(@color, @board, [row, 1])
		@pieces[:n2] = Knight.new(@color, @board, [row, 6])

		if @color == :white
			8.times do |col|
				@pieces["p#{col}".to_sym] = WhitePawn.new(@color, @board, [1, col])
			end
		else
			8.times do |col|
				@pieces["p#{col}".to_sym] = BlackPawn.new(@color, @board, [6, col])
			end
		end

	end

	def get_move
		moves = [[2,3], ["a","b"]]
		until valid_input?(moves)
			puts "#{@name}, What's your move? (input coordinates for start and end positions ex: 72, 74) "
			moves = gets.chomp.split(',').map(&:strip)
			moves.map! {|el| el.split(//)}
			moves.map! do |move|
				move.map!(&:to_i)
			end
			puts "hmmm, please try entering your moves again please" unless valid_input?(moves)
			puts "your move #{moves}"
		end

		moves
	end
	##tests to make sure there are 2 coordinates, each with 2 fixnums in_bounds
	def valid_input?(moves)
		valid = true
		return false unless moves.length == 2
		moves.each do |coord|
			return false unless coord.length == 2
			coord.each do |row_or_col|
				return false unless row_or_col.is_a?(Fixnum) &&
														row_or_col <= 7 && row_or_col >= 0
			end
		end

		valid
	end
end


class Piece
	attr_accessor :alive, :color, :position

	def initialize(color, board, position = nil)
		@color = color
		@alive = true
		@position = position
		@board = board

		board.add_piece(self)
	end

	def render
		color = @color == :white ? 0 : 1
		symbol[color]
	end

end

class SlidingPiece < Piece

	UP_DOWN_SIDE = [[1, 0], [0, 1], [-1, 0], [0, -1]]

	DIAGONAL =[[-1, -1], [1, 1], [1, -1], [-1, 1]]

	def moves
		possible_moves = []
		sliding_moves.each do |move|
			free_path = true
			destination = @position + move
			while in_bounds(destination) && free_path
				possible_moves << move
				if @board[position] != nil?
					free_path = false
				end
				destination += move
			end
		end
		possible_moves
	end

	def in_bounds(position)
		@board.in_bounds?(position)
	end

	def sliding_moves

	end

end
#all pieces will validate that they can reach destination
#position via one of their available moves times their multiplier
class Queen < SlidingPiece
	def initialize(color, board, position = nil)
		super(color, board, position)
	end

	def symbol
		["♕", "♛"]
	end

	def sliding_moves
		UP_DOWN_SIDE + DIAGONAL
	end
end

class King < Piece
	def initialize(color, board, position = nil)
		super(color, board, position)
	end

	def symbol
		["♔", "♚"]
	end

	def moves
		possible_moves = []
		sliding_moves.each do |move|
			destination = @position + move
			if in_bounds(destination)
				possible_moves << move
			end
		possible_moves
	end
end

class Bishop < SlidingPiece

	def initialize(color, board, position = nil)
		super(color, board, position)
	end

	def symbol
		["♗", "♝"]
	end

	def sliding_moves
		DIAGONAL
	end
end

class Rook < SlidingPiece

	def initialize(color, board, position = nil)
		super(color, board, position)
	end

	def symbol
		["♖", "♜"]
	end

	def sliding_moves
		UP_DOWN_SIDE
	end

end

class Knight < Piece

	def initialize(color, board, position = nil)
		super(color, board, position)
		@moves = [[2, 1], [2, -1], [-1, 2], [1, 2], [-2,1], [-2,-1], [-1,-2], [1,-2]]
	end

	def symbol
		["♘", "♞"]
	end

	def moves
		possible_moves = []
		@moves.each do |move|
			destination = @position + move
			if in_bounds(destination)
				possible_moves << move
			end
		possible_moves
	end
end

class Pawn < Piece
	def initialize
		@first_move = true
	end

	def symbol
		["♙", "♟"]
	end

	def forward
		##
	end

	def my_moves
		[[0, forward], [0,forward*2]] if @first_move
		[0, forward] if !first_move
	end

	def moves
		check_for_neighbors
		possible_moves = []
		my_moves.each do |move|
			destination = @position + move
			if in_bounds(destination)
				possible_moves << move
			end
		end

		possible_moves + check_for_neighbors(possible_moves)
	end

	def check_for_neighbors(possible_moves)
		moves = [[@position[0] + forward, @position[1] + 1], [@position[0] + forward, @position[1] + 1]]
		moves.keep_if { |move| @board.in_bounds?(move) }
		neighbors = moves.map { |move| @board[move] }
		neighbors.keep_if { |neighbor| neighbor1 != nil && neighbor1.color != @color }

		neighbors
	end

end

class BlackPawn < Pawn

	def initialize(color, board, position = nil)
		super(color, board, position)
	end

	def forward
		-1
	end

end

class WhitePawn < Pawn
	def initialize(color, board, position = nil)
		super(color, board, position)
	end

	def forward
		1
	end
end

g = Game.new