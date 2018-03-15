require 'pry'
class Board
  INITIAL_MARKER = ' '
  def initialize
    @squares = {}
    (1..9).each { |key| @squares[key] = INITIAL_MARKER }
  end

  def get_square_at(space)
    @squares[space]
  end

  def set_square_at(square_number, marker)
    @squares[square_number] = marker
  end

  def square_available?(square_number)
    @squares[square_number] == ' '
  end
end

class Square
  def initialize(marker)
    @marker = marker
  end

  def to_s
    @marker
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
  attr_reader :board, :human, :computer
  def initialize
    @board = Board.new
    @human = Player.new('X')
    @computer = Player.new('O')
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

  def display_board
    row_border = '     |     |'
    row_separator = '-----+-----+-----'
    puts ''
    [1,4,7].each do |row_start|
      puts row_border
      print_mid_row(row_start,board)
      puts row_border
      puts row_separator if row_start < 7
    end
    puts ''
  end

  def human_moves
    square_number = nil
    puts 'Choose a square between 1-9: '
    loop do
      square_number = gets.chomp.to_i
      break if (1..9).include?(square_number) && 
        board.square_available?(square_number)
      puts "Sorry, choice must be between 1 and 9 and the square must be empty."
    end

    human.mark_square(board, square_number)  
  end

  def play
    display_welcome_message
    loop do
      display_board
      human_moves
      display_board # temp
      break
      break if someone_won? || board_full?

      computer_moves
      break if someone_won? || board_full?
    end
    # display_result
    display_goodbye_message
  end
end

game = TTTGame.new
game.play