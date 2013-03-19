class Board

	attr_reader :board

	def initialize()
		@board = Array.new(8) { [nil]*8 }
	end

	def update_pawns

	end

	def piece_at(position)
		@board[position[0]][position[1]]
	end
	#test for in check and in bounds here, in the board
	#test for legal move in piece
	#test for not running self over in HumanPlayer

	def in_check?

	end

	def in_bounds?

		#return true if in bounds
	end


	def place_piece(piece)
	end
	private
	def remove_piece(piece)
		#when killed or when moved
	end

end

class Game

	attr_accessor :board, :player1, :player2

	def initialize
		@board = Board.new
		@player1 = Human_Player.new(:white)
		@player2 = Human_Player.new(:black)
	end

	def play

		counter = 1


		current_player = @player1
		if counter.odd?
			current_player = @player1
		else
			current_player = @player2
		end

		make_move(current_player)

		counter +=1

		# else push back
		# call @board.place_piece
		#
	end

	def make_move(player)
		start_pos, end_pos = player.get_move
		chosen_piece = @board.piece_at(start_pos)
		until chosen_piece.valid_move?(end_pos) &&
			@board.valid_move?(start_pos, end_pos)
			start_pos, end_pos = player.get_move
			chosen_piece = @board.piece_at(start_pos)
		end
		@board.place_piece
	end




end


class Human_Player

	def get_move
		#returns array of start pos and end pos
	end

end

#all pieces will validate that they can reach destination
#position via one of their available moves times their multiplier
class Queen

	def valid_move?
	end

end

class King

	def valid_move?
	end

end

class Bishop

	def valid_move?
	end

end

class Rook

	def valid_move?
	end

end

class Knight

	def valid_move?
	end

end

class Pawn

	def valid_move?
	end

end