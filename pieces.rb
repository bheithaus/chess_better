# encoding: utf-8
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