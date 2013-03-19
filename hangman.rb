require 'Debugger'

class Game
  attr_reader :secretword

  def initialize
    @number_of_guess = 0
    @human = Human.new
    @computer = Computer.new
    @secret_word = ""
    @solution_in_progress = []
    @chosen_word_length = 0
    @guesses = []
    @bad_guesses = []
    play_game
  end

  def win?
    !@solution_in_progress.include?('_')
  end

  def lose?
    @guesses.length == 11
  end

  def play_game
    puts "Who shall choose the SECRET WORD? You or me, #{@human.name}?"
    game_mode = gets.chomp.downcase
    until game_mode == "me" or game_mode == "you"
      puts "invalid entry, try again :)"
      game_mode == gets.chomp.downcase
    end
    case game_mode
      when "you"
        human_guesser_mode
      when "me"
        computer_guesser_mode
    end
  end

  def draw
    print @solution_in_progress.join(' ')
    puts "\n"
  end

  def computer_guesser_mode
    #human picks a word
    puts "#{@human.name.capitalize} think of a word:  "
    puts "Okay! Tell me the length of your word!"
    @chosen_word_length = @human.get_secretword_length
    puts "\n"
    solution_in_progress_maker
    @computer.learn_length_of_word(@chosen_word_length)

    until win? or lose?
      @guesses << @computer.guess #get a guess from smart computer
      letter_location = @human.location_in_secret(@guesses.last)
      if letter_location.nil?
        @computer.bad_guess
      else
        @computer.good_guess
        edit_solution(@guesses.last, letter_location)
      end
      draw
    end
    if win?
      puts "you win :)"
    else
      puts "you lose :("
    end
  end

  def solution_in_progress_maker
    @chosen_word_length.times { @solution_in_progress << '_' }
  end

  def edit_solution(letter, letter_location)
    letter_location.each do |spot| #[4 , 3 ]
      #debugger
      @solution_in_progress[spot] = letter
    end
  end

  def human_guesser_mode
    @guesses = []
    @chosen_word_length = @computer.secretword_generator.length
    solution_in_progress_maker
    puts "Guess a letter in my word. Hint my word is #{@chosen_word_length} letters long \n"
    draw
    until win? or lose?
			valid = false
			while !valid
				begin
	     		@guesses << @human.get_guess
					valid = true
				rescue ArgumentError => e
					puts "can't get guess"
					puts "error: #{e.message}"
				end
			end
      places_with_letter = @computer.check_guess(@guesses.last)
      if !places_with_letter.nil?
        edit_solution(@guesses.pop, places_with_letter)
      end
      puts "Secret Word \n"
      draw
      puts "Already guessed #{@guesses.join(" ")}"
    end
    if win?
      puts "you win!"
    else
      puts "you lost!"
    end
  end
end

class Human
  attr_reader :name

  def initialize(name = "Sally")
    @name = name
  end

  def get_guess
    puts "Guess a letter"
    letter = gets.chomp.downcase
    unless (letter =~ /[a-z]/) == 0
      raise ArgumentError.new "thats not a letter!"
    end
    letter
  end

  def location_in_secret(letter)  # [ , , ]  #hello
    puts "Hey, is this letter in your word? #{letter.upcase}\nIf so, at which positions in the word? (first is 0) please put a space in between multiple number entries, thanks \n If not, press n"
    response = gets.chomp
    if response == 'n' || response == 'N'
      nil
    else
      response.split(" ").map!{ |item| item.to_i }
    end
  end

  def get_secretword_length
    length_of_secret = gets.chomp
    until (length_of_secret =~ /\d/) == 0
      puts "invalid entry, try again :)"
      length_of_secret = gets.chomp
    end
    length_of_secret.to_i
  end
end

class Computer

  def initialize(name = "Big Red")
    @name = name
    @dictionary = []
		begin
    	load_dictionary
		rescue ArgumentError => e
			puts "Can't load dictionary"
			puts "the error was: #{e.message}"
		rescue SystemCallError => e
			puts "Can't load dictionary"
			puts "the error was: #{e.message}"
			puts "try another?"
			file = gets.chomp
			load_dictionary(file)
		end
    @secret_word = ''
    @possible_words = []

    @computer_guesses = []
  end

  def load_dictionary(file = 'dict.tx')
    File.foreach(file) { |line| @dictionary << line.chomp }
		if @dictionary.empty?
			raise ArgumentError.new "This dictionary is empty"
		end
  end

  def secretword_generator
    @secret_word = @dictionary.sample
  end

  def check_guess(letter)
    places_with_letter = []
    #debugger
    secret = @secret_word.dup
    if secret.include?(letter)
      secret.split("").each_with_index do |spot, index|
        if spot == letter
          places_with_letter << index
        end
      end
      places_with_letter
    else
      nil
    end
  end

  def good_guess  # do this if letter is in the secret word
    @possible_words.select { |word| word.include?(@computer_guesses[-1]) }
  end

  def bad_guess # do this if letter is NOT in the secret word
    @possible_words.delete_if { |word| word.include?(@computer_guesses[-1]) }
  end

  def guess
    frequency_letters = Hash.new(0)
    @possible_words.each do |word|
      word.each_char { |letter| frequency_letters[letter] += 1 }
    end
    frequency_letters.delete_if { |letter, freq| @computer_guesses.include?(letter) }
    @computer_guesses << frequency_letters.sort_by { |letter, frequency| frequency }.last[0]
    @computer_guesses.last
  end

  def learn_length_of_word(length)
    @possible_words = @dictionary.select { |word| word.length == length }
  end
end

a=Game.new