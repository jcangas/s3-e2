class Array
  def to_square_name
    (self[0] +  "a".ord).chr + (self[1] +  '1'.ord).chr
  end

  def sum(other)
    self.zip(other).map do |pair|
      a = pair[0] || 0
      b = pair[1] || 0
      a + b
    end
  end
end

class String
  def to_square
    [self[0].ord - "a".ord, self[1].ord - '1'.ord ]
  end
end

module Pressman

  module Color
    Empty = 0
    White = 2
    Black = 4

    def self.to_ord(value)
      value / 2 - 1
    end

    def self.to_s(value)
      ['', 'White', 'Black'][value / 2]
    end
  end

  class Board
    attr :player, true
    attr :stones
    attr :flash, true

    def initialize(display)
      @display = display
    end

    def start
      @board = []
      2.times do
        @board << [Color::White]*8
      end
      4.times do
        @board << [Color::Empty]*8
      end
      2.times do
        @board << [Color::Black]*8
      end
      @stones = [16, 16]
    end

    def [](square)
      sqr = (square.is_a?(String) ? square.to_square : square)
      @board[sqr[0]][sqr[1]]
    end

    def []=(square, value)
      @board[square[0]][square[1]] = value
    end

    def oponent
      player == Color::White ? Color::Black : Color::White
    end

    def is_empty?(square)
      self[square] == Color::Empty
    end

    def is_friend?(asquare)
      occupied_by?(asquare, @player)
    end

    def occupied_by?(asquare, aplayer)
      self[asquare] == aplayer
    end

    def clear!(square)
      self[square] = Color::Empty
    end

    def kill_stone_at(square)
      return if is_empty?(square)
      stones[Color.to_ord(self[square])] -= 1
      clear!(square)
    end

    def draw
      @display.say '   1   2   3   4   5   6   7   8'
      row_labels = "abcdefgh"
      row_sep = '  ' + "-"*(4*8)
      @board.each_index do |idx|
        @display.say row_sep
        row = @board[idx].map {|square| [' ', 'o', 'x'][square / 2]}.join(' | ')
        @display.say "#{row_labels[idx]}| #{row} |"
      end
      @display.say row_sep
      stones_txt = [Color::Black, Color::White].map{ |c| Color.to_s(c) + " = #{stones[Color.to_ord(c)]}"}.join('  ')
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

    def stones
      @board.stones
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

      board.kill_stone_at squares[1]
      board[squares[1]] = board[squares[0]]
      board.clear!(squares[0])
    end

  private

    def parse_move(text)
        text.split('-').map{|sqr_name| sqr_name.to_square}
    end

    def validate_move(squares)
      raise "You don't have a stone in #{squares[0].to_square_name}" unless board.is_friend?(squares[0])
      delta = [squares[1][0] - squares[0][0], squares[1][1] - squares[0][1]]

      # can move along rows or columns. In this case or row not change or column not change
      is_straight = (delta[1]*delta[0] == 0)
      # can move along diagonals. In this case the change rate rows / columns == 1
      is_diagonal = !is_straight && ((delta[1] / delta[0]).abs == 1)

      raise "Invalid move" unless (is_straight ||  is_diagonal)
      occupied = first_between(squares)
      occupied = squares[1] if board.is_friend?(squares[1])
      raise "Square #{occupied.to_square_name} is occupied" if occupied
    end

    def first_between(squares)
      delta = [squares[1][0] - squares[0][0], squares[1][1] - squares[0][1]]
      step =  delta.map {|c| c <=> 0 } # map to sign
      checked = squares[0].sum(step)
      while checked != squares[1]
        return checked unless board.is_empty?(checked)
        checked = checked.sum(step)
      end
      nil
    end
  end
end

