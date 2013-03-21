# encoding: utf-8

require 'debugger'

class Board
	attr_reader :matrix

	def initialize
		@matrix = Array.new(8) { [nil]*8 }
	end

	###>?????
	def [](position)
		x, y = position
		@matrix[x][y]
	end

	def []=(position, set_to)
		x, y = position
		@matrix[x][y] = set_to
	end

	def add_piece(piece, matrix = @matrix)
		row, col = piece.position
		matrix[row][col] = piece
	end

	def piece_at(position)
		self[position]
	end

	def valid_move?(start_pos, end_pos, player, enemy)
		d_matrix = dup
		move_piece(start_pos, end_pos, d_matrix)
		!in_check?(player, enemy, d_matrix)
	end

	def dup
		dupped_board = Board.new
			@matrix.each_with_index do |row, i|
			row.each_with_index do |piece, j|
				 dupped_board.matrix[i][j] = piece.nil? ? nil : piece.dup(dupped_board)
			end
		end
		dupped_board.matrix
	end

	#potentially check-making move has been made before this function is called
	#end_pos is king's position
	def in_check?(player, enemy, matrix = @matrix)
		king_pos = player.pieces[:k].position
		#puts "player is #{player.color}"
		#puts "king_pos is #{king_pos}"
		#puts "enemy is #{enemy.color}"
		enemy.pieces.each do |key, piece|
		#	puts "#{piece} piece"
			piece.moves.each do |move|
			#	puts "#{move} moves for each enemy piece"
				return true if move == king_pos
			end
		end

		false
	end

	def in_bounds?(position) #end_position
		position.all? { |x| x >= 0 && x <= 7 }
	end

	#after current player moves, sends in their enemy's king position and themself as "enemy"
	def check_mate?(player, enemy)
		king_pos = player.pieces[:k].position
		player.pieces.each do |key, piece|
			piece.moves.each do |move|
				d_matrix = dup
				d_position = piece.position
				move_piece(d_position, move, d_matrix)
				return false if !in_check?(player, enemy, d_matrix)
			end
		end

		true
	end

	def move_piece(start_pos, end_pos, matrix = @matrix)
		mover = matrix[start_pos[0]][start_pos[1]]
		remove_piece(mover, matrix)
		mover.position = end_pos
		add_piece(mover, matrix)
	end

	def print_board
		print_board = Array.new(8) { ["_"]*8 }
		@matrix.each_with_index do |row, i|
			row.each_with_index do |square, j|
				unless square == nil
					print_board[i][j] = square.render
				end
			end
		end

		print_board
	end

private

	def remove_piece(removed_piece, matrix = @matrix)
		puts "here"
		unless removed_piece.nil?
			start_pos = removed_piece.position
					puts "#{start_pos} start pos in remove"
			removed_piece.position = nil
			matrix[start_pos[0]][start_pos[1]] = nil
		end
	end
end

class Game
	attr_accessor :board, :player1, :player2

	def initialize

		@board = Board.new
		@player1 = Human_Player.new(:white, @board, "Brian")
		@player2 = Human_Player.new(:black, @board, "April")
		play
	end

	def play
		counter = 1
		check_mate = false
		until check_mate
			show
			players = counter.odd? ? [@player1, @player2] : [@player2, @player1]
			if @board.in_check?(players[0], players[1])
				puts "#{players[0]} you're in Check!"
			end
			make_move(players[0], players[1])
			counter +=1

			unless @board.in_check?(players[1], players[0])
				check_mate = false
			else
				check_mate = @board.check_mate?(players[1], players[0])###????)
			end
		end
		show
		puts "Game Over: Check Mate! #{players[1].name} wins "
	end

	def make_move(player, enemy)
		start_pos, end_pos = player.get_move(@board)
		chosen_piece = @board.piece_at(start_pos)
		until chosen_piece.valid_move?(end_pos) &&
			@board.valid_move?(start_pos, end_pos, player, enemy)
			### enter here if user's first choice was invalid
			start_pos, end_pos = player.get_move(@board)
			chosen_piece = @board.piece_at(start_pos)
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
	attr_reader :name, :pieces, :color

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

		row = @color == :white ? 1 : 6

		8.times do |col|
			@pieces["p#{col}".to_sym] = Pawn.new(@color, @board, [row, col])
		end
	end

	def get_move(board)
		moves = [[2,3], ["a","b"]]
		until valid_input?(moves, board)
			puts "#{@name}, What's your move? (input coordinates for start and end positions ex: 712, 74) "
			moves = gets.chomp.split(',').map(&:strip)
			moves.map! {|el| el.split(//)}
			moves.map! do |move|
				move.map!(&:to_i)
			end
			puts "hmmm, please try entering your moves again please" unless valid_input?(moves, board)
		end

		moves
	end
	##tests to make sure there are 2 coordinates, each with 2 fixnums in_bounds
	def valid_input?(moves, board)
		return false if board[moves[0]] == nil
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
	attr_accessor :color, :position

	def initialize(color, board, position = nil)
		@color = color
		@position = position
		@board = board

		board.add_piece(self)
	end

	def valid_move?(move)
		moves.include?(move)
	end

	def dup(board)
		dup = self.class.new(@color, board, @position)
		dup
	end

	def render
		color = @color == :white ? 0 : 1
		symbol[color]
	end

	def in_bounds(position)
		@board.in_bounds?(position)
	end
end

class SlidingPiece < Piece

	UP_DOWN_SIDE = [[1, 0], [0, 1], [-1, 0], [0, -1]]

	DIAGONAL =[[-1, -1], [1, 1], [1, -1], [-1, 1]]

	def moves
		possible_moves = []
		sliding_moves.each do |move|
			free_path = true
			destination = [@position[0] + move[0], @position[1] + move[1]]
			while in_bounds(destination) && free_path
				unless @board[destination] == nil
					if @board[destination].color == @color
						break
					end
					free_path = false
				end
				possible_moves << destination
				destination = [destination[0] + move[0], destination[1] + move[1]]
			end
		end

		possible_moves
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

class King < SlidingPiece
	def initialize(color, board, position = nil)
		super(color, board, position)
	end

	def symbol
		["♔", "♚"]
	end

	def sliding_moves
		UP_DOWN_SIDE + DIAGONAL
	end

	def moves
		possible_moves = []
		sliding_moves.each do |move|
			destination = [@position[0] + move[0], @position[1] + move[1]]
			if in_bounds(destination)
				if @board[destination] != nil && @board[destination].color != @color
					possible_moves << destination
				end
			end
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
			destination = [@position[0] + move[0], position[1] + move[1]]
			if in_bounds(destination)
				possible_moves << destination
			end
		end

		possible_moves
	end
end

class Pawn < Piece
	def initialize(color, board, position)
		super(color, board, position)
		@first_move = true
		@forward = @color == :white ? 1 : -1
	end

	def position=(pos)
		@first_move = false
		@position = pos
	end
	def symbol
		["♙", "♟"]
	end

	def my_moves
		return [[@forward, 0], [@forward*2, 0]] if @first_move
		return [[@forward, 0]] if !@first_move
	end

	def moves
		possible_moves = []
		my_moves.each do |move|
			destination = [@position[0] + move[0], position[1] + move[1]]
			if in_bounds(destination)
				target = @board[destination]
				if target == nil
					possible_moves << destination
				else
					break
				end
			end
		end

		possible_moves + neighbor_moves(possible_moves)
	end

	def neighbor_moves(possible_moves)

		moves = [[@position[0] + @forward, @position[1] - 1], [@position[0] + @forward, @position[1] + 1]]
		moves.select! { |move| @board.in_bounds?(move) }
		neighbors = moves.map { |move| @board[move] }
		neighbors.select! { |neighbor| neighbor != nil && neighbor.color != @color }
		neighbors.map { |neighbor| neighbor.position }
	end
end

g = Game.new