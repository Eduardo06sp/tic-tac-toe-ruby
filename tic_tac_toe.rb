# frozen_string_literal: true

# REFACTOR: Probably wanna add MORE CLASSES
# Possibilities can inherit from GameBoard
# TicTacToe, Player, GameBoard, Possibilities < Gameboard
# maybe even a play ROUND class??? (overkill?)
# REPLY TO ROSE WHEN DONE!!!

# TerminalInterface contains styling used to display the banner, gameboard, possibilities board and score
module TerminalInterface
  def display_title
    puts "-----------------------------------------------------
    \n----------------- TIC - TAC - TOE -------------------
    \n-----------------------------------------------------"
  end

  def display_board
    puts "\t    |   |        |       |    | \n" \
      "\t  #{board[:A1]} | #{board[:B1]} | #{board[:C1]}      |    " \
      "#{possibilities[:A1]} | #{possibilities[:B1]} | #{possibilities[:C1]}\n" \
      "\t----|---|----    |   ----|----|----\n" \
      "\t  #{board[:A2]} | #{board[:B2]} | #{board[:C2]}      |    " \
      "#{possibilities[:A2]} | #{possibilities[:B2]} | #{possibilities[:C2]}\n" \
      "\t----|---|----    |   ----|----|----\n" \
      "\t  #{board[:A3]} | #{board[:B3]} | #{board[:C3]}      |    " \
      "#{possibilities[:A3]} | #{possibilities[:B3]} | #{possibilities[:C3]}\n" \
      "\t    |   |        |       |    | "
  end

  def display_score
    puts "-----------------------------------------------------
    \n---- Score: --- #{p1.name}: #{p1.score} -- #{p2.name}: #{p2.score} ------
    \n-----------------------------------------------------"
  end
end

# TicTacToe creates a new object representing a new match. Its instance variables are updated throughout the game.
# Its board and possibilities are reset if the user decides to rematch.
class TicTacToe
  include TerminalInterface

  attr_accessor :turn, :board, :possibilities
  attr_reader :p1, :p2

  def initialize(p1, p2)
    @p1 = p1
    @p2 = p2
    @board = { A1: ' ', B1: ' ', C1: ' ',
               A2: ' ', B2: ' ', C2: ' ',
               A3: ' ', B3: ' ', C3: ' ' }
    @possibilities = { A1: 'A1', B1: 'B1', C1: 'C1',
                       A2: 'A2', B2: 'B2', C2: 'C2',
                       A3: 'A3', B3: 'B3', C3: 'C3' }
    @turn = p1.name
  end

  def display_game
    display_title
    display_board
    display_score
  end

  def space_empty?(play)
    board[play.to_sym] == ' '
  end

  def update_board(play, player_symbol)
    board[play.to_sym] = player_symbol

    possibilities[play.to_sym] = %i[C1 C2 C3].include?(play.to_sym) ? player_symbol.to_s : " #{player_symbol}"
  end

  def winner?(player_symbol)
    win_possibilities = [
      %w[A1 B1 C1],
      %w[A2 B2 C2],
      %w[A3 B3 C3],

      %w[A1 A2 A3],
      %w[B1 B2 B3],
      %w[C1 C2 C3],

      %w[A1 B2 C3],
      %w[A3 B2 C1]
    ]

    player_spaces_hash = board.select do |space|
      board[space] == player_symbol
    end

    player_spaces_array = player_spaces_hash.to_a.flatten
    player_spaces_symbols = player_spaces_array.select do |el|
      el.is_a?(Symbol)
    end
    player_symbols_array = player_spaces_symbols.map(&:to_s)

    win_possibilities.any? do |possibility|
      possibility.all? { |el| player_symbols_array.include?(el) }
    end
  end

  def tie?
    board.none? do |space|
      space[1] == ' '
    end
  end

  def change_turn
    self.turn = turn == p1.name ? p2.name : p1.name
  end

  def end_match(player)
    if player == p1.name
      p1.score += 1
    else
      p2.score += 1
    end

    display_game

    puts "Congratulations #{player}, you've won!"
  end

  def rematch
    puts 'Rematch?'
    puts 'You may type in yes/y/no/n.'
    input = gets.chomp.strip

    until %w[yes y no n].include?(input)
      puts 'Please enter yes or no.'
      input = gets.chomp.strip
    end

    if %w[yes y].include?(input)
      self.board = { A1: ' ', B1: ' ', C1: ' ',
                     A2: ' ', B2: ' ', C2: ' ',
                     A3: ' ', B3: ' ', C3: ' ' }

      self.possibilities = { A1: 'A1', B1: 'B1', C1: 'C1',
                             A2: 'A2', B2: 'B2', C2: 'C2',
                             A3: 'A3', B3: 'B3', C3: 'C3' }
      display_game
      play_rounds
    else
      puts 'Have a wonderful day! Thanks for playing :}'
    end
  end

  def play_rounds
    player_symbol = turn == p1.name ? p1.symbol : p2.symbol

    puts "(#{player_symbol}) #{turn}, make your move."

    play = gets.chomp.upcase
    until space_empty?(play)
      puts 'Please choose an available space!'
      play = gets.chomp.upcase
    end

    update_board(play, player_symbol)

    if winner?(player_symbol)
      end_match(turn)
      rematch
    elsif tie?
      display_game
      puts "It's a tie!"
      rematch
    else
      display_game
      change_turn
      play_rounds
    end
  end
end

class Player
  attr_accessor :score
  attr_reader :name, :symbol

  def initialize(name, symbol)
    @name = name
    @symbol = symbol
    @score = 0
  end
end

def intro
  puts 'You may type in lower case.'
  puts "Please enter player one's name (or just press enter to use the default)"

  p1_name = gets.chomp
  p1_name = p1_name == '' ? 'Player_one' : p1_name

  p1_symbol = nil
  until %w[X O].include?(p1_symbol)
    puts "#{p1_name}, choose \"X\" or \"O\"!"
    p1_symbol = gets.chomp.upcase
  end

  puts "Enter player two's name (or press enter to use the default)"
  p2_name = gets.chomp
  p2_name = p2_name == '' ? 'Player_two' : p2_name

  p2_symbol = p1_symbol == 'X' ? 'O' : 'X'

  p1 = Player.new(p1_name, p1_symbol)
  p2 = Player.new(p2_name, p2_symbol)
  new_match = TicTacToe.new(p1, p2)

  new_match.display_game
  new_match.play_rounds
end

intro
