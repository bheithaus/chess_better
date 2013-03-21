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