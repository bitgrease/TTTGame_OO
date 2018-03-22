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
  attr_reader :marker, :name
  def initialize(name, marker)
    @marker = marker
    @name = name
    @scorecard = Scorecard.new(5)
  end

  def mark_square(board, square_number)
    board[square_number] = marker
  end

  def reset_score
    @scorecard.reset
  end

  def add_point
    @scorecard.add_point
  end

  def won_match?
    games_won == 5
  end

  def games_won
    @scorecard.total
  end
end

class TTTGame
  COMPUTER_NAMES = %w[Computer Hal iRoomba]
  MARKERS = %w[X O]
  WINNING_COMBOS = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7],
                    [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]
  attr_reader :board, :human, :computer, :current_player
  def initialize
    @board = Board.new
    @human ||= Player.new(select_player_name({ human: true }), select_marker)
    @computer = Player.new(select_player_name, select_marker({ human: false }))
    @current_player = @human
    @rejected_play_again = false
  end

  def select_player_name(player_type={ human: false })
    name = nil
    if player_type[:human]
      loop do
        print "What's your name?: "
        name = gets.chomp
        break unless name =~ /[^a-z|0-9]/i || name.empty?
        puts "Sorry, you must enter a valid name (alphanumeric chars only)."
      end
    else
      name = COMPUTER_NAMES.sample
    end
    name
  end

  def player_marker_selection
    marker = nil
    loop do
      print "Please select a mark to use #{joinor(MARKERS)}: "
      marker = gets.chomp.upcase
      break if MARKERS.include?(marker)
      puts "Sorry, you must enter a valid marker."
    end
    marker
  end

  def computer_marker_selection
    marker = nil
    begin
      marker = if human.marker == MARKERS.first
                 MARKERS.last
               else
                 MARKERS.first
               end
    rescue StandardError
      @human = Player.new(select_player_name({ human: true }), select_marker)
      retry
    end
    marker
  end

  def select_marker(player_type={ human: true })
    if player_type[:human]
      player_marker_selection
    else
      computer_marker_selection
    end
  end

  def play
    clear_screen
    display_welcome_message
    loop do
      loop do
        play_and_score_single_game
        break if match_won? || !play_again?
        reset_board
        display_play_again_message
      end

      display_match_score_and_winner if match_won?
      break unless play_again?
      display_play_again_message
      reset_match_scores_and_board
    end
    display_goodbye_message
  end

  private

  def play_and_score_single_game
    clear_screen
    display_board_and_score
    play_one_game
    find_winner_and_display_result
  end

  def play_one_game
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

  def display_name_and_marks
    print "#{human.name} is #{human.marker}. "
    puts "#{computer.name} is #{computer.marker}."
    puts ''
  end

  def display_match_score
    puts 'Match Score:'
    print "#{human.name}: #{human.games_won} - "
    puts "#{computer.name}: #{computer.games_won}"
  end

  def display_board_and_score
    display_name_and_marks
    display_match_score
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
    square_number = prompt_for_square
    human.mark_square(board, square_number)
  end

  def prompt_for_square
    square_number = nil
    print "Select a square from one of the available spaces.\n" \
          "(#{joinor(board.unmarked_keys)}): "
    loop do
      square_number = gets.chomp.to_i
      break if board.unmarked_keys.include?(square_number)
      print "Invalid choice. Please try again\n" \
           "Choose from the following list (#{joinor(board.unmarked_keys)}): "
    end
    square_number
  end

  def computer_moves
    square_idx = computer_offense_square || computer_defense_square
    square_idx ||= 5 if board.square_available?(5)

    if square_idx
      computer.mark_square(board, square_idx)
    else
      computer.mark_square(board, board.unmarked_keys.sample)
    end
  end

  def find_winner_and_display_result
    update_winner_scorecard
    clear_screen_and_display_board
    case winning_marker
    when human.marker then puts "You won this game!"
    when computer.marker then puts "Computer won this game!"
    else
      puts "This game is a TIE."
    end
  end

  def update_winner_scorecard
    case winning_marker
    when human.marker then human.add_point
    when computer.marker then computer.add_point
    end
  end

  def clear_screen
    system('cls') || system('clear')
  end

  def play_again?
    return false if @rejected_play_again
    answer = nil
    loop do
      print 'Do you want to play again (y/n)? '
      answer = gets.chomp.downcase
      break if %w[y n].include?(answer)
      puts 'You must answer with a y or n.'
    end

    @rejected_play_again = true if answer == 'n'
    answer == 'y'
  end

  def reset_board
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
    current_player.marker == human.marker
  end

  def match_won?
    human.won_match? || computer.won_match?
  end

  def display_match_score_and_winner
    display_match_score
    winner_name = human.won_match? ? human.name : computer.name
    puts "#{winner_name} wins the match!"
  end

  def at_risk_square
    square_idx = nil
    WINNING_COMBOS.each do |line|
      squares = board.values_at(*line)
      if squares.map(&:marker).count(human.marker) == 2
        empty_square = squares.map(&:marker).index(Square::INITIAL_MARKER)
        square_idx = line[empty_square] if empty_square
      end
    end
    square_idx
  end

  def square_to_complete_line(marker)
    square_idx = nil
    WINNING_COMBOS.each do |line|
      squares = board.values_at(*line)
      if squares.map(&:marker).count(marker) == 2
        empty_square = squares.map(&:marker).index(Square::INITIAL_MARKER)
        square_idx = line[empty_square] if empty_square
      end
    end
    square_idx
  end

  def computer_defense_square
    square_to_complete_line(human.marker)
  end

  def computer_offense_square
    square_to_complete_line(computer.marker)
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
    reset_board
  end
end

system('cls') || system('clear')
game = TTTGame.new
game.play
