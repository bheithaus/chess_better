require './board'
require './pieces'

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
				check_mate = @board.check_mate?(players[1], players[0])
			end
		end
		show
		puts "Game Over: Check Mate! #{players[0].name} wins "
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
			puts "#{@name}, What's your move? (input coordinates for start and end positions ex: 10, 30) "
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

g = Game.new
