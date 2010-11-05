
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
    HomeColors = [ Color::White, Color::White, Color::Empty, Color::Empty,
                    Color::Empty, Color::Empty, Color::Black, Color::Black]
    attr :player, true
    attr :stone_count
    attr :flash, true

    def initialize(display)
      @display = display
      @board =  Array.new(8){ [Color::Empty]*8 }
      @stone_count = [64, 0, 0]
    end

    def [](square)
      sqr = square.to_square
      @board[sqr[0]][sqr[1]]
    end

    def []=(square, value)
      sqr = square.to_square
      stone_count[Color.to_ord(stone(sqr))] -= 1
      @board[sqr[0]][sqr[1]] = value
      stone_count[Color.to_ord(stone(sqr))] += 1
    end

    def home_color(square)
      HomeColors[square[0]]
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

    def put_stone(square)
      self[square] = player
    end

    def kill_stone(square)
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

  private
    def empty_setup
      (0..7).each do |row|
        (0..7).each do |col|
          clear!([row, col])
        end
      end
    end

    def game_setup
      for row in 0..7 do
        for col in 0..7 do
          self[[row, col]] = home_color([row, col])
        end
      end
    end
  end
end

