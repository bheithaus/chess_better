# if time, add method: check_user_input
class Game
  COLORS = [:R,:G,:Y,:B,:O,:P]

  def initialize
    @guesses = []
    @responses = []
    @computers_solution = []
    @player = HumanPlayer.new
    @number_of_turns = 0
    @matches = []
    play_loop
  end

  def play_loop
    puts "would you like to play?  (y or n)"
    play = gets.chomp.downcase
    if play == 'y'
      computer_guess
      play_game
    end
  end

  def draw_board
    @guesses.each_with_index { |item, index| print "#{item}  |  Result:"+
    " #{@matches[index][0]} perfect matches and #{@matches[index][1]} near"+
    " matches\n" }
    puts "the answer is: #{@computers_solution}"
  end

  def play_game
    until win? or lose?
      draw_board
      guess = @player.get_guess
      # reroute to make them use valid guess
      if valid_guess?(guess)
				@guesses << guess
			else
				raise ArgumentError.new "not a valid guess"
			end
      # need if?
      result = evaluate_guess
      @matches << result
      @number_of_turns = @guesses.length
      puts "here are your previous guesses" unless win?
    end
    if win?
      puts "good, guess! you win"
    else
      puts "you lose"
    end
  end


  def valid_guess?(guess)
    !guess.map{ |color| COLORS.include?(color) }.include?(false)
  end

  def computer_guess
    @computers_solution = []
    4.times { @computers_solution << COLORS.sample }
  end

  def evaluate_guess
    #debugger
    near_match = 0
    exact_match = 0
    evaluation = @computers_solution.dup
    guess = @guesses.last.dup # make sure we don't need dup
    guess.each_with_index do |color, index|
      if color == @computers_solution[index]
        evaluation[index] = :m
        guess[index] = :m
        exact_match += 1
      end
    end
    guess.each_with_index do |color, index|  #near match
      if evaluation.include?(color) && COLORS.include?(color)
        evaluation[evaluation.index(color)] = :n
        guess[index] = :n
        near_match += 1
      end
    end

    [exact_match, near_match]
  end

  def win?
    @computers_solution == @guesses.last
  end

  def lose?
    @number_of_turns == 11
  end

end

class HumanPlayer
  def get_guess
    puts "Please enter your guess: Example 'G G B R'"
    guess = gets.chomp.upcase.split(" ")
    guess.map! { |item| item.to_sym }
  end
end

a = Game.new