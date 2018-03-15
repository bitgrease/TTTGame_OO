require 'pry'
class Board
  INITIAL_MARKER = 'X'
  def initialize
    @squares = {}
    (1..9).each { |key| @squares[key] = INITIAL_MARKER }
  end

  def get_square_at(space)
    @squares[space]
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
  def initialize
  end

  def mark
  end
end

class TTTGame
  attr_reader :board
  def initialize
    @board = Board.new
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

  def display_board(board)
    row_border = '     |     |'
    row_separator = '_____+_____+_____'
    puts ''
    [1,4,7].each do |row_start|
      puts row_border
      print_mid_row(row_start,board)
      puts row_border
      puts row_separator if row_start < 7
    end
    puts ''
  end

  def play
    display_welcome_message
    loop do
      display_board(board)
      first_player_moves
      break if someone_won? || board_full?

      second_player_moves
      break if someone_won? || board_full?
    end
    display_result
    display_goodbye_message
  end
end

game = TTTGame.new
game.play