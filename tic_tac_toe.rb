require 'pry'
class Board
  WINNING_COMBOS = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7],
                    [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]
  def initialize
    @squares = {}
    reset
  end

  def get_square_at(space)
    @squares[space]
  end

  def set_square_at(square_number, marker)
    @squares[square_number].marker = marker
  end

  def square_available?(square_number)
    @squares[square_number].unmarked?
  end

  def full?
    unmarked_keys.empty?
  end

  def num_of_mark(player_mark)
    @squares.count { |_, square| square.marker == player_mark }
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def someone_won?
    winner?(TTTGame::HUMAN_MARKER) || winner?(TTTGame::COMPUTER_MARKER)
  end

  def winner?(marker)
    WINNING_COMBOS.any? do |combo|
      combo.all? { |key| get_square_at(key).marker == marker }
    end
  end

  def reset
    (1..9).each { |n| @squares.store(n, Square.new) }
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker
  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    @marker == INITIAL_MARKER
  end
end

class Player
  attr_reader :marker
  def initialize(marker)
    @marker = marker
  end

  def mark_square(board, square_number)
    board.set_square_at(square_number, marker)
  end
end

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  attr_reader :board, :human, :computer
  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
  end

  def display_welcome_message
    puts 'Welcome to Tic Tac Toe!'
    puts ''
  end

  def display_goodbye_message
    puts 'Thanks for playing Tic Tac Toe! Goodbye!'
  end

  def print_mid_row(starting_square, board)
    print "  #{board.get_square_at(starting_square)}  |"
    print "  #{board.get_square_at(starting_square + 1)}  |"
    puts "  #{board.get_square_at(starting_square + 2)}"
  end

  def print_top_border_with_key(row_start)
    puts "#{row_start}    |#{row_start + 1}    |#{row_start + 2}"
  end
# 
#   def display_board(options={clear_screen: true})
#     clear_screen if options[:clear_screen]
#     puts "You are #{HUMAN_MARKER}. Computer is #{COMPUTER_MARKER}"
#     row_separator = '-----+-----+-----'
#     row_bottom_border = '     |     |'
#     puts ''
#     [1, 4, 7].each do |row_start|
#       puts row_bottom_border
#       print_mid_row(row_start, board)
#       print_top_border_with_key(row_start)
#       puts row_separator if row_start < 7
#     end
#     puts ''
#   end
  
  def display_board
    puts "You are #{HUMAN_MARKER}. Computer is #{COMPUTER_MARKER}"
    row_separator = '-----+-----+-----'
    row_bottom_border = '     |     |'
    puts ''
    [1, 4, 7].each do |row_start|
      puts row_bottom_border
      print_mid_row(row_start, board)
      print_top_border_with_key(row_start)
      puts row_separator if row_start < 7
    end
    puts ''
  end
  
  def clear_screen_and_display_board
  	clear_screen
  	puts "You are #{HUMAN_MARKER}. Computer is #{COMPUTER_MARKER}"
    row_separator = '-----+-----+-----'
    row_bottom_border = '     |     |'
    puts ''
    [1, 4, 7].each do |row_start|
      puts row_bottom_border
      print_mid_row(row_start, board)
      print_top_border_with_key(row_start)
      puts row_separator if row_start < 7
    end
    puts ''
  end

  def human_moves
    square_number = nil
    available_keys_formatted = board.unmarked_keys.join(' ,')
    print "Select a square from one of the available spaces.\n" \
          "(#{available_keys_formatted}): "
    loop do
      square_number = gets.chomp.to_i
      break if board.unmarked_keys.include?(square_number)
      print "Invalid choice. Please try again\n" \
           "Choose one (#{available_keys_formatted}): "
    end

    human.mark_square(board, square_number)
  end

  def computer_moves
    computer.mark_square(board, board.unmarked_keys.sample)
  end

  def find_winner_and_display_result
    if board.winner?(HUMAN_MARKER)
      puts "You won!"
    elsif board.winner?(COMPUTER_MARKER)
      puts "Computer won."
    else
      puts "It's a TIE."
    end
  end

  def clear_screen
    system('cls') || system('clear')
  end

  def play_again?
    answer = nil
    loop do
      print 'Do you want to play again (y/n)? '
      answer = gets.chomp.downcase
      break if %w[y n].include?(answer)
      puts 'You must answer with a y or n.'
    end

    answer == 'y'
  end

  def play
    clear_screen
    display_welcome_message

    loop do
      display_board
      loop do
        human_moves
        break if board.someone_won? || board.full?

        computer_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board
      end

      clear_screen_and_display_board
      find_winner_and_display_result
      break unless play_again?
      board.reset
      clear_screen
      puts "Let's play again!\n"
    end

    display_goodbye_message
  end
end

game = TTTGame.new
system('cls') || system('clear')
game.play
