# encoding: utf-8

class PrintClass

	attr_accessor :white, :black

	def initialize
		white = {}
		white[:k] = "♔"
		white[:q] = "♕"
		white[:r] = "♖"
		white[:n] = "♗"
		white[:b] = "♘"
		white[:p] = "♙"
		@white = white

		black = {}
		black[:k] = "♚"
		black[:q] = "♛"
		black[:r] = "♜"
		black[:n] = "♝"
		black[:b] = "♞"
		black[:p] = "♟"
		@black = black
	end
end


class Board

	attr_reader :board

	def initialize(set1, set2)
		@board = Array.new(8) { [nil]*8 }
		initialize_pieces(set1, set2)
	end

	#don't look at this :)
	def initialize_pieces(set1, set2)

		@board[0][0] = set1[:r1]
		set1[:r1].position = [0,0]
		@board[0][1] = set1[:n1]
		set1[:n1].position = [0,1]
		@board[0][2] = set1[:b1]
		set1[:b1].position = [0,2]
		@board[0][3] = set1[:k]
		set1[:k].position = [0,3]
		@board[0][4] = set1[:q]
		set1[:q].position = [0,4]
		@board[0][5] = set1[:b2]
		set1[:b2].position = [0,5]
		@board[0][6] = set1[:n2]
		set1[:n2].position = [0,6]
		@board[0][7] = set1[:r2]
		set1[:r2].position = [0,7]

		@board[1][0] = set1[:p1]
		set1[:p1].position = [1,0]
		@board[1][1] = set1[:p2]
		set1[:p2].position = [1,1]
		@board[1][2] = set1[:p3]
		set1[:p3].position = [1,2]
		@board[1][3] = set1[:p4]
		set1[:p4].position = [1,3]
		@board[1][4] = set1[:p5]
		set1[:p5].position = [1,4]
		@board[1][5] = set1[:p6]
		set1[:p6].position = [1,5]
		@board[1][6] = set1[:p7]
		set1[:p7].position = [1,6]
		@board[1][7] = set1[:p8]
		set1[:p8].position = [1,7]

		#set2
		@board[7][0] = set2[:r1]
		set2[:r1].position = [7,0]
		@board[7][1] = set2[:n1]
		set2[:n1].position = [7,1]
		@board[7][2] = set2[:b1]
		set2[:b1].position = [7,2]
		@board[7][3] = set2[:q]
		set2[:q].position = [7,3]
		@board[7][4] = set2[:k]
		set2[:k].position = [7,4]
		@board[7][5] = set2[:b2]
		set2[:b2].position = [7,5]
		@board[7][6] = set2[:n2]
		set2[:n2].position = [7,6]
		@board[7][7] = set2[:r2]
		set2[:r2].position = [7,7]

		@board[6][0] = set2[:p1]
		set2[:p1].position = [6,0]
		@board[6][1] = set2[:p2]
		set2[:p2].position = [6,1]
		@board[6][2] = set2[:p3]
		set2[:p3].position = [6,2]
		@board[6][3] = set2[:p4]
		set2[:p4].position = [6,3]
		@board[6][4] = set2[:p5]
		set2[:p5].position = [6,4]
		@board[6][5] = set2[:p6]
		set2[:p6].position = [6,5]
		@board[6][6] = set2[:p7]
		set2[:p7].position = [6,6]
		@board[6][7] = set2[:p8]
		set2[:p8].position = [6,7]
	end

	def update_pawns(end_pos)
		# if mover is not a pawn
		#still need to write if mover is a pawn
		moving_piece = @board[end_pos[0]][end_pos[1]]
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
		maybe_pawn_positions.each { |pos| maybe_pawns << @board[pos[0]][pos[1]] }
		maybe_pawns.each do |maybe_pawn|
				if maybe_pawn.class == WhitePawn || maybe_pawn.class == BlackPawn
					maybe_pawn.new_neighbor(moving_piece)
				end
		end
	end

	def piece_at(position)
		@board[position[0]][position[1]]
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
			return false if @board[intermediate_pos[0]][intermediate_pos[1]] != nil
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
		x = position[0]
		y = position[1]
		x >= 0 && x <= 7 && y >= 0 && y <= 7
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
		i, j = start_pos
		piece = @board[i][j]
		remove_piece(start_pos)
		i, j = end_pos
		@board[i][j] = piece
		update_pawns(end_pos)
	end

	def print_board
		printer = PrintClass.new()
		print_board = Array.new(8) { ["_"]*8 }
		@board.each_with_index do |row, i|
			row.each_with_index do |col, j|
				unless col == nil
					print_board[i][j] = get_display_piece(col, printer)
				end
			end
		end

		print_board
	end

	def get_display_piece(piece, printer)
		color = piece.color
		if color == :white
			hash = printer.white
		else
			hash = printer.black
		end
		print_out = ""
		current_class = piece.class
		if current_class == Queen
			print_out = hash[:q]
		elsif current_class == King
			print_out = hash[:k]
		elsif current_class == Bishop
			print_out = hash[:b]
		elsif current_class == Knight
			print_out = hash[:n]
		elsif current_class == Rook
			print_out = hash[:r]
		elsif current_class == BlackPawn || WhitePawn
			print_out = hash[:p]
		end
		print_out
	end

private

	def remove_piece(start_pos)
		i, j = start_pos
		removed_piece = @board[i][j]
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
		maybe_pawn_positions.each { |pos| maybe_pawns << @board[pos[0]][pos[1]] }
		maybe_pawns.each do |maybe_pawn|
				if maybe_pawn.class == WhitePawn || maybe_pawn.class == BlackPawn
					maybe_pawn.remove_neighbor(removed_piece)
				end
		end

		@board[i][j] = nil
		#remove pawn neighbor
	end
end

class Game
	attr_accessor :board, :player1, :player2

	def initialize
		@player1 = Human_Player.new(:white, "bill")
		@player2 = Human_Player.new(:black, "jane")
		@board = Board.new(@player1.pieces, @player2.pieces)
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
		start_pos, end_pos = player.get_move
		chosen_piece = @board.piece_at(start_pos)
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

	def initialize(color, name = "blank")
		@name = name
		@color = color
		make_team
	end

	def make_team
		@pieces = {}

		@pieces[:q] = Queen.new(@color)
		@pieces[:k] = King.new(@color)
		@pieces[:r1] = Rook.new(@color)
		@pieces[:r2] = Rook.new(@color)
		@pieces[:b1] = Bishop.new(@color)
		@pieces[:b2] = Bishop.new(@color)
		@pieces[:n1] = Knight.new(@color)
		@pieces[:n2] = Knight.new(@color)

		if @color == :white
			@pieces[:p1] = WhitePawn.new(@color)
			@pieces[:p2] = WhitePawn.new(@color)
			@pieces[:p3] = WhitePawn.new(@color)
			@pieces[:p4] = WhitePawn.new(@color)
			@pieces[:p5] = WhitePawn.new(@color)
			@pieces[:p6] = WhitePawn.new(@color)
			@pieces[:p7] = WhitePawn.new(@color)
			@pieces[:p8] = WhitePawn.new(@color)

		else
			@pieces[:p1] = BlackPawn.new(@color)
			@pieces[:p2] = BlackPawn.new(@color)
			@pieces[:p3] = BlackPawn.new(@color)
			@pieces[:p4] = BlackPawn.new(@color)
			@pieces[:p5] = BlackPawn.new(@color)
			@pieces[:p6] = BlackPawn.new(@color)
			@pieces[:p7] = BlackPawn.new(@color)
			@pieces[:p8] = BlackPawn.new(@color)
		end
	end

	def get_move
		puts "#{@name}, What's your move? (input coordinates for start and end positions ex: 72, 74) "
		moves = gets.chomp.split(',').map(&:strip)
		moves.map! {|el| el.split(//)}
		moves.map! do |move|
			move.map!(&:to_i)
		end
		puts "my move #{moves}"
		moves
	end
end


class Piece
	attr_accessor :alive, :color, :position

	def initialize(color, position = nil)
		@color = color
		@alive = true
		@position = position
	end

end

#all pieces will validate that they can reach destination
#position via one of their available moves times their multiplier
class Queen < Piece
	def initialize(color, position = nil)
		super(color, position)
		@moves = [ [-1,-1], [1,1], [1,0], [0,1], [1,-1], [-1,1], [-1,0], [0,-1] ]
		@multiplier = 8
	end

	def valid_move?(end_pos)
		@moves.each do |move|
			@multiplier.times do |mult|
				if @position + move * mult == end_pos
					return move
				end
			end
		end

		false
	end

end

class King < Piece

	def initialize(color, position = nil)
		super(color, position)
		@moves = [ [-1,-1], [1,1], [1,0], [0,1], [1,-1], [-1,1], [-1,0], [0,-1] ]
	end

	def valid_move?(end_pos)
		@moves.each do |move|
			if @position + move == end_pos
				return move
			end
		end

		false
	end
end

class Bishop < Piece

	def initialize(color, position = nil)
		super(color, position)
		@moves = [ [-1,-1], [1,1], [1,-1], [-1,1] ]
		@multiplier = 8
	end

	def valid_move?(end_pos)
		@moves.each do |move|
			@multiplier.times do |mult|
				if @position + move * mult == end_pos
					return move
				end
			end
		end

		false
	end
end

class Rook < Piece

	def initialize(color, position = nil)
		super(color, position)
		@moves = [ [-1,0], [1,0], [0,-1], [0,1] ]
		@multiplier = 8
	end

	def valid_move?(end_pos)
		@moves.each do |move|
			@multiplier.times do |mult|
				if @position + move * mult == end_pos
					return move
				end
			end
		end

		false
	end
end

class Knight < Piece

	def initialize(color, position = nil)
		super(color, position)
		@moves = [[2, 1], [2, -1], [-1, 2], [1, 2], [-2,1], [-2,-1], [-1,-2], [1,-2]]
	end

	def valid_move?(end_pos)
		@moves.each do |move|
			if @position + move == end_pos
				return move
			end
		end

		false
	end

end

class Pawn < Piece
end

class BlackPawn < Pawn

	def initialize(color, position = nil)
		super(color, position)
		@moves = [[0,-1],[0,-2]]
		@first_move = true
	end

	def valid_move?(end_pos)
		@moves.each do |move|
			if @position + move == end_pos
				return move
			end
		end

		false
	end

	def new_neighbor(neighb)
	 	if neighb.color != @color
	 			@moves << [neighb.position[0] - @position[0], neighb.position[1] - @position[1]]
	 	end
	end

	def remove_neighbor(neighb)
		move = [neighb.position[0] - @position[0], neighb.position[1] - @position[1]]
		if @moves.include?(move)
			@moves.delete(move)
		end
	end
end

class WhitePawn < Pawn

	def initialize(color, position = nil)
		super(color, position)
		@moves = [[0, 1],[0, 2]]
		@first_move = true
	end

	def valid_move?(end_pos)
		@moves.each do |move|
			if @position + move == end_pos
				return move
			end
		end

		false
	end

	def new_neighbor(neighb)
	 	if neighb.color != @color
	 			@moves << [neighb.position[0] - @position[0], neighb.position[1] - @position[1]]
	 	end
	end

	def remove_neighbor(neighb)
		move = [neighb.position[0] - @position[0], neighb.position[1] - @position[1]]
		if @moves.include?(move)
			@moves.delete(move)
		end
	end

end

g = Game.new