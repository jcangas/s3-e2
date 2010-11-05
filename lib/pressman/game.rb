# We use 2 ways for denote a board square:
# As an array of board indexes, like [2,5]. Indexes are in range 0..7.
# We say this is "a square"
# As a algebraic coordinate, like "c5". Analog to chess. Rows are a..h and columns are 1..8.
# We say this is "a coordinate"


class Array
  def to_coord
    sum(["a".ord, '1'.ord ]).map {|c| c.chr}.join
  end

  def to_square
    self
  end

  # operate squares like vectors
  def sum(other)
    self.zip(other).map do |pair|
      pair[0].to_i + pair[1].to_i
    end
  end

  def subs(other)
    self.zip(other).map do |pair|
      pair[0].to_i - pair[1].to_i
    end
  end

end

class String
  def to_square
   # [self[0].ord - "a".ord, self[1].ord - '1'.ord ]
    [self[0].ord, self[1].ord].subs ["a".ord, '1'.ord ]
  end

  def to_coord
    self
  end
end

module Pressman

  module Color
    Empty = 0
    White = 2
    Black = 4

    def self.to_ord(value)
      value / 2
    end

    def self.to_s(value)
      ['', 'White', 'Black'][to_ord(value)]
    end
  end

  class Board
    attr :player, true
    attr :stone_count
    attr :flash, true

    def initialize(display)
      @display = display
      @board =  Array.new(8){ ['']*8 }
    end

    def start
      game_setup
    end

    def empty_setup
      @stone_count = [0, 0, 0]
      (0..7).each do |row|
        (0..7).each do |col|
          clear!([row, col])
        end
      end
    end

    def game_setup
      @stone_count = [0, 0, 0]
      for row in 0..7 do
        for col in 0..7 do
          if (0..1).include?(row)
            @player = Color::White
          elsif (6..7).include?(row)
            @player = Color::Black
          elsif
            @player = Color::Empty
          end
          new_stone([row, col])
        end
      end
    end

    def [](square)
      sqr = square.to_square
      @board[sqr[0]][sqr[1]]
    end

    def []=(square, value)
      sqr = square.to_square
      @board[sqr[0]][sqr[1]] = value
    end

    def oponent
      player == Color::White ? Color::Black : Color::White
    end

    def top(color)
      (color == Color::Black) ? 0 : 7
    end

    def bottom(color)
      (color == Color::Black) ? 7 : 0
    end

    def clear!(square)
      self[square] = Color::Empty
    end

    # Board has 2 sides of equal size. The top side is assigned to White
    def side(square)
      (0..3).include?(square[0]) ? Color::White : Color::Black
    end

    # color of the stone at  square.
    def stone(square)
      (self[square] / 2 ) * 2 # to ignore stone deactivation
    end

    def occupied_by?(square, color)
      stone(square) == color
    end

    def is_empty?(square)
      occupied_by?(square, Color::Empty)
    end

    def is_occupied?(square)
      !is_empty?(square)
    end

    # Stone behaivior. This methods operates "onthe stone" at square

    def stone_top(square)
      top(stone(square))
    end

    def stone_bottom(square)
      bottom(stone(square))
    end

    def new_stone(square)
      self[square] = player
      stone_count[Color.to_ord(stone(square))] += 1
    end

    def kill_stone(square)
      return if is_empty?(square)
      stone_count[Color.to_ord(stone(square))] -= 1
      clear!(square)
    end

    def deactivate_stone(square)
      return if is_empty?(square) || !stone_activated?(square)
      self[square] += 1
    end

    def activate_stone(square)
      return if is_empty?(square) || stone_activated?(square)
      self[square] -= 1
    end

    def stone_activated?(square)
      is_occupied?(square) && (self[square] % 2 == 0)
    end

    # check if stone is smae color as current player
    def friend_stone?(square)
      occupied_by?(square, player)
    end

    def stone_at_side?(square)
      side(square) == stone(square)
    end

    def stone_at_top?(square)
      square[0] == stone_top(square)
    end

    def draw
      @display.say '   1   2   3   4   5   6   7   8'
      row_labels = "abcdefgh"
      row_sep = '  ' + "-"*(4*8)
      @board.each_index do |idx|
        @display.say row_sep
        row = @board[idx].map {|square| [' ', ' ', 'o', 'O', 'x', 'X'][square]}.join(' | ')
        @display.say "#{row_labels[idx]}| #{row} |"
      end
      @display.say row_sep
      stones_txt = [Color::Black, Color::White].map{ |c| Color.to_s(c) + " = #{stone_count[Color.to_ord(c)]}"}.join('  ')
      @display.say "Stones: #{stones_txt}"
      @display.say "#{flash}" if flash
      flash = nil
      @display.say "#{Color::to_s(player)} move?"
    end
  end

  class Game
    attr :board

    def initialize(display)
      @display = display
      @board = Board.new(display)
    end

    def start
      @display.say 'Welcome to Pressman Game!'
      board.start
      board.player = Color::Black
      board.draw
    end

    def player
      @board.player
    end

    def oponent
      @board.oponent
    end

    def stone_count
      @board.stone_count
    end

    def input(command)
      begin
        case command
          when /[a-h]\d-[a-h]\d/
            move command
            board.player = board.oponent
          when 'q'
            exit
        end
      rescue Exception => e
        board.flash = command + " error!: " + e.message
      end
      board.draw
    end

    def move(move)
      squares = move.is_a?(String) ? parse_move(move) : move

      validate_move(squares)

      board.kill_stone squares[1]
      board[squares[1]] = board[squares[0]]
      board.clear!(squares[0])

      check_regeneration(squares[1])
      check_reactivation(squares[1])
    end

  private

    def parse_move(text)
      text.split('-').map{|coord| coord.to_square}
    end

    def validate_move(squares)
      raise "You don't have a stone in #{squares[0].to_coord}" unless board.friend_stone?(squares[0])

      delta = squares[1].subs squares[0]
      # can move along rows or columns. In this case or row not change or column not change
      is_straight = (delta[1]*delta[0] == 0)
      # can move along diagonals. In this case the change rate rows / columns == 1
      is_diagonal = (delta[0] != 0) && ((delta[1] / delta[0]).abs == 1)

      raise "Invalid move" unless (is_straight ||  is_diagonal)

      occupied = first_between(squares, :is_occupied?)
      occupied = squares[1] if board.friend_stone?(squares[1])
      raise "Square #{occupied.to_coord} is occupied" if occupied
    end

    def first_between(squares, condition, inclusive = nil)
      step =  squares[1].subs(squares[0]).map {|c| c <=> 0 } # map to signum
      checked = squares[0]
      checked = checked.sum(step) if !inclusive
      while checked != squares[1]
        return checked if board.send(condition, checked)
        checked = checked.sum(step)
      end
      return checked if inclusive && board.send(condition, checked)
      nil
    end

    def check_regeneration(square)
      return unless board.stone_activated?(square)
      return unless board.stone_at_top?(square)

      board.deactivate_stone(square)

      bottom = [board.stone_bottom(square), 0]
      bottom_row = [bottom, bottom.sum([0, 7])]

      free_square = first_between(bottom_row, :is_empty?, :inclusive)
      return unless free_square
      board.new_stone(free_square)
    end

    def check_reactivation(square)
      board.activate_stone(square) if board.stone_at_side?(square)
    end
  end
end

