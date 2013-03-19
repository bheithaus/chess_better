class Board

	attr_reader :board

	def initialize(set1, set2)
		@board = Array.new(8) { [nil]*8 }
		intialize_pieces(set1, set2)
	end

	#don't look at this :)
	def initialize_pieces(set1, set2)
		#initialize set1
		@board[0][0] = set1[:r1]
		set1[:r1].positon = [0,0]
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
		set1[:p1].positon = [1,0]
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
		set2[:r1].positon = [7,0]
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
		set2[:p1].positon = [6,0]
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
		false
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
		@moves = [ [-1,-1], [1,1], [1,0], [0,1], [1,-1], [-1,1], [-1,0], [0,-1] ]
		@multiplier = 8
	end

	def valid_move?(end_pos)
		@moves.each do |move|
			@multiplier.times do |mult|
				if @position + move * mult == end_pos
					return true
				end
			end
		end
		false
	end

end

class King < Piece

	def initialize(color, position)
		super(color, position)
		@moves = [ [-1,-1], [1,1], [1,0], [0,1], [1,-1], [-1,1], [-1,0], [0,-1] ]
		@multiplier = 1
	end

	def valid_move?(end_pos)
		@moves.each do |move|
			@multiplier.times do |mult|
				if @position + move * mult == end_pos
					return true
				end
			end
		end
		false
	end


end

class Bishop < Piece

	def initialize(color, position)
		super(color, position)
	end

	def valid_move?
	end

end

class Rook < Piece

	def initialize(color, position)
		super(color, position)
	end

	def valid_move?
	end

end

class Knight < Piece

	def initialize(color, position)
		super(color, position)
	end

	def valid_move?
	end

end

class Pawn < Piece

	def initialize(color, position)
		super(color, position)
	end

	def valid_move?
	end

end