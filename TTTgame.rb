require 'pry'
class Board
  INITIAL_MARKER = ' '
  def initialize
    @squares = {}
    (1..9).each { |key| @squares[key] = Square.new(INITIAL_MARKER) }
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
    @squares.none? { |_, square| square.unmarked? }
  end

  def num_of_mark(player_mark)
    @squares.count { |_, square| square.marker == player_mark}
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end
end

class Square
  attr_accessor :marker
  def initialize(marker)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    @marker == Board::INITIAL_MARKER
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


  def display_board
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

  def someone_won?
    # 1, 2, 3  4, 5, 6  7,8,9
    # 1, 4, 7  2, 5, 8  3, 6, 9
    # 1, 5, 9  3, 5, 7
    winning_combos = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7],
                      [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]

    winning_combos.any? do |combo|
      combo.all? { |key| board.get_square_at(key).marker == HUMAN_MARKER } ||
        combo.all? { |key| board.get_square_at(key).marker == COMPUTER_MARKER }
    end
  end

  def human_moves
    square_number = nil
    puts "Select a square from one of the available spaces."
    print "Choose one: #{board.unmarked_keys}: "
    loop do
      square_number = gets.chomp.to_i
      break if board.unmarked_keys.include?(square_number)
      puts "Invalid choice. Please try again."
      print "Choose one:#{board.unmarked_keys}: "
    end


    human.mark_square(board, square_number)
  end

  def computer_moves
    computer.mark_square(board, board.unmarked_keys.sample)
  end

  def winner?(player)
    winning_combos = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7],
                      [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]

    winning_combos.any? do |combo|
      combo.all? { |key| board.get_square_at(key).marker == player.marker }
    end
  end

  def find_winner_and_display_result
    if winner?(human)
      puts "Human won!"
    elsif winner?(computer)
      puts "Computer won."
    else
      puts "It's a TIE."
    end
  end

  def clear_screen
    system('cls') || system('clear')
  end

  def play
    clear_screen
    display_welcome_message
    display_board
    loop do
      human_moves
      break if someone_won? || board.full?

      computer_moves
      break if someone_won? || board.full?
      clear_screen
      display_board
    end
    clear_screen
    display_board
    find_winner_and_display_result
    display_goodbye_message
  end
end

game = TTTGame.new
game.play
