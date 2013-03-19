class Board

	attr_reader :board

	def initialize(set1, set2)
		@board = Array.new(8) { [nil]*8 }
		intialize_pieces(set1, set2)
	end


	def initialize_pieces(set1, set2)
		set1.each


	end

	def update_pawns

	end

	def piece_at(position)
		@board[position[0]][position[1]]
	end
	#test for in check and in bounds here, in the board
	#test for legal move in piece
	#test for not running self over in HumanPlayer
	def valid_move?
		#calls in_check? and in_bounds?
		end

	def in_check?

	end

	def in_bounds?

		#return true if in bounds
	end

	def check_mate?

	end


	def place_piece(piece)
		#calls update_pawns

	end

	private

	def remove_piece(piece)
		#when killed or when moved
	end
end

class Game

	attr_accessor :board, :player1, :player2

	def initialize
		@player1 = Human_Player.new(:white)
		@player2 = Human_Player.new(:black)
		@board = Board.new(@player1.pieces, @player2.pieces)
	end

	def play
		counter = 1
		until @board.check_mate?
			if counter.odd?
				current_player = @player1
			else
				current_player = @player2
			end
			make_move(current_player)
			counter +=1
		end
		puts "Game Over: Check Mate! #{current_player.name} wins "


	end

	def make_move(player)
		start_pos, end_pos = player.get_move
		chosen_piece = @board.piece_at(start_pos)
		until chosen_piece.valid_move?(end_pos) &&
			@board.valid_move?(start_pos, end_pos)
			start_pos, end_pos = player.get_move
			chosen_piece = @board.piece_at(start_pos)
		end
		@board.move_piece(start_pos,end_pos)
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
		@pieces[:p1] = Pawn.new(@color)
		@pieces[:p2] = Pawn.new(@color)
		@pieces[:p3] = Pawn.new(@color)
		@pieces[:p4] = Pawn.new(@color)
		@pieces[:p5] = Pawn.new(@color)
		@pieces[:p6] = Pawn.new(@color)
		@pieces[:p7] = Pawn.new(@color)
		@pieces[:p8] = Pawn.new(@color)



	end

	def get_move
		puts "What's your move? (input coordinates for start and end positions ex: 72, 74) "
		moves = gets.chomp.split(',').map(&:strip).map(&:to_i)
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

	def initialize(color, position)
		super(color, position)


	end

	def valid_move?
	end

end

class King < Piece

	def initialize(color)
		super(color)


	end

	def valid_move?
	end

end

class Bishop < Piece

	def initialize(color)
		super(color)


	end

	def valid_move?
	end

end

class Rook < Piece

	def initialize(color)
		super(color)


	end

	def valid_move?
	end

end

class Knight < Piece

	def initialize(color)
		super(color)


	end

	def valid_move?
	end

end

class Pawn < Piece

	def initialize(color)
		super(color)


	end

	def valid_move?
	end

end