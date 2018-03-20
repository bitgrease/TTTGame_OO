require 'pry'

class Scorecard
  attr_accessor :total
  def initialize(winning_score)
    @total = 0
    @winning_score = winning_score
  end

  def add_point
    self.total += 1
  end

  def winner?
    total == @winning_score
  end

  def reset
    self.total = 0
  end
end

class Board
  ROW_START_INDEXES = [1, 4, 7]

  def initialize
    @squares = {}
    reset
  end

  def []=(square_location, marker)
    @squares[square_location].marker = marker
  end

  def values_at(pos1, pos2, pos3)
    @squares.values_at(pos1, pos2, pos3)
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
    !!winner
  end

  def draw
    row_separator = '-----+-----+-----'
    row_bottom_border = '     |     |'
    ROW_START_INDEXES.each do |row_start|
      puts row_bottom_border
      print_mid_row(row_start)
      print_top_border_with_key(row_start)
      puts row_separator if row_start < ROW_START_INDEXES.last
    end
  end

  def reset
    (1..9).each { |n| @squares.store(n, Square.new) }
  end

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.uniq.size == 1
  end

  private

  def print_mid_row(starting_square)
    print "  #{@squares[starting_square]}  |"
    print "  #{@squares[starting_square + 1]}  |"
    puts "  #{@squares[starting_square + 2]}"
  end

  def print_top_border_with_key(row_start)
    puts "#{row_start}    |#{row_start + 1}    |#{row_start + 2}"
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

  def marked?
    !unmarked?
  end
end

class Player
  attr_reader :marker, :name, :scorecard
  def initialize(marker, player_type={human: false})
    @marker = marker
    if player_type[:human]
      set_name
    else
      @name = 'Computer'
    end

    @scorecard = Scorecard.new(5)
  end

  def set_name
    name = nil
    loop do
      print "What's your name?: "
      name = gets.chomp
      break unless name =~ /[^a-z|0-9]/i || name.empty?
      puts "Sorry, you must enter a valid name (alphanumeric chars only)."
    end
    @name = name
  end

  def mark_square(board, square_number)
    board[square_number] = marker
  end

  def reset_score
    scorecard.rest
  end

  def add_point
    scorecard.add_point
  end

  def won_match?
    games_won == 5
  end

  def games_won
    scorecard.total
  end
end

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  WINNING_COMBOS = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7],
                    [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]
  attr_reader :board, :human, :computer, :current_player
  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER, {human: true})
    @computer = Player.new(COMPUTER_MARKER)
    @current_player = @human
  end

  def play
    clear_screen
    display_welcome_message
    loop do
      loop do
        display_board_and_score
        single_game
        update_winner_scorecard
        find_winner_and_display_result
        break if match_won? || !play_again?
        reset
        display_play_again_message
      end

      display_match_score_and_winner
      break unless play_again?
      display_play_again_message
      reset_match_scores
    end
    display_goodbye_message
  end

  private

  def single_game
    loop do
      current_player_moves
      break if someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def display_welcome_message
    puts 'Welcome to Tic Tac Toe!'
    puts ''
  end

  def display_goodbye_message
    puts 'Thanks for playing Tic Tac Toe! Goodbye!'
  end

  def display_board_and_score
    puts "#{human.name} is #{HUMAN_MARKER}. Computer is #{COMPUTER_MARKER}."
    puts ''
    puts 'Current score is:'
    puts "#{human.name}: #{human.games_won} - #{computer.name}: #{computer.games_won}"
    board.draw
    puts ''
  end

  def someone_won?
    !!winning_marker
  end

  def clear_screen_and_display_board
    clear_screen
    display_board_and_score
  end

  def joinor(numbers, separator=', ', join_word='or')
    case numbers.size
    when 0 then ''
    when 1 then numbers.first
    when 2 then numbers.join(" #{join_word} ")
    else
      numbers[-1] = "#{join_word} #{numbers.last}"
      numbers.join(separator)
    end
  end

  def human_moves
    square_number = nil
    print "Select a square from one of the available spaces.\n" \
          "(#{joinor(board.unmarked_keys)}): "
    loop do
      square_number = gets.chomp.to_i
      break if board.unmarked_keys.include?(square_number)
      print "Invalid choice. Please try again\n" \
           "Choose from the following list (#{joinor(board.unmarked_keys)}): "
    end

    human.mark_square(board, square_number)
  end

  def computer_moves
    square = at_risk_square
    if square
      computer.mark_square(board, square)
    else
      computer.mark_square(board, board.unmarked_keys.sample)
    end
  end

  def find_winner_and_display_result
    clear_screen_and_display_board
    case winning_marker
    when HUMAN_MARKER then puts "You won!"
    when COMPUTER_MARKER then puts "Computer won!"
    else
      puts "It's a TIE."
    end
  end

  def update_winner_scorecard
    case winning_marker
    when HUMAN_MARKER then human.add_point
    when COMPUTER_MARKER then computer.add_point
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

  def reset
    board.reset
    @current_player = human
    clear_screen
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ''
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_player = computer
    else
      computer_moves
      @current_player = human
    end
  end

  def human_turn?
    current_player.marker == HUMAN_MARKER
  end

  def match_won?
    human.won_match? || computer.won_match?
  end

  def display_match_score_and_winner
    puts 'The final score was: '
    print "#{human.name}: #{human.scorecard.total} - "
    puts "#{computer.name}: #{computer.scorecard.total}"

    if human.won_match?
      puts "#{human.name} wins!"
    else
      puts "#{computer.name} wins."
    end
  end

  def at_risk_square
    square = nil
    WINNING_COMBOS.each do |line|
      squares = board.values_at(*line)
      if squares.map{ |sq| sq.marker }.count(HUMAN_MARKER) == 2
        space_index = squares.map do |sq| 
          sq.marker 
        end.index(Square::INITIAL_MARKER)
        square = line[space_index] if space_index
      end
    end
    square
  end

  def winning_marker
    WINNING_COMBOS.each do |combo|
      squares = board.values_at(*combo)
      if board.three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset_match_scores
    human.reset_score
    computer.reset_score
  end
end

system('cls') || system('clear')
game = TTTGame.new
game.play
