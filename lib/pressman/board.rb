
  # Board captures the state of the game play and know some basics facts in order to help
  # the Game class. Note this a Pressman:: Board not a "generic"" Board, so it knows some basics
  # facts about a Pressman's board ...
  # It's all about 'static' facts of the game: Board don't know game's dynamics nor game rules

  # We use 2 ways for denote a board square:
  # 1) As an array of board indexes in range 0..7, like [2,5].
  #   We say this is "a square"
  #
  # 2) As a algebraic coordinate analog to chess, like "c5".
  #   Rows are a..h and columns are 1..8.  We say this is "a coordinate"

module Pressman

  class Board

    attr_accessor :player # current player
    attr_reader :stones   # stone count for each player
    attr_reader :max_row
    attr_reader :max_column

    def initialize(rows, columns)
      @max_row = rows - 1
      @max_column = columns - 1
      @board =  Array.new(rows){ [nil]*columns }
      @stones = {:black => 0, :white => 0}
    end

    # Square <-> Coordinate conversions

    def to_square(coord)
      return coord if coord.is_a? Array
      [coord[0].ord - "a".ord, coord[1].ord - '1'.ord]
    end

    def to_coord(square)
      return square if square.is_a? String
      [ square[0] + "a".ord, square[1] + '1'.ord ].map {|c| c.chr}.join
    end

    # current oponent
    def oponent
      player == :white ? :black : :white
    end

    # Some facts about the board

    # Board has 2 zones of equal size. The top side is assigned to White
    def zone(square)
      (0 .. (@max_row / 2)).include?(square[0]) ? :white : :black
    end

    # Each player has top & bottom rows.

    # Bottom is the first row in player's initial game setup.
    def bottom(player)
      (player == :black) ? @max_row : 0
    end

    # Top is the oponent's bottom
    def top(player)
      (player == :black) ? 0 : @max_row
    end

    # Helper methods to query board about some basics facts

    def is_empty?(square)
      self[square].nil?
    end

    def is_occupied?(square)
      self[square]
    end

    def occupied_by?(square, player)
      is_occupied?(square) && self[square].color == player
    end

    # check if square contains a stone of current player
    def friend?(square)
      occupied_by?(square, player)
    end

    # check if the stone in square is in their home zone
    def at_home?(square)
      zone(square) == self[square].color
    end

    # check square is in player "Top" row
    def at_top?(square, player)
      square[0] == top(player)
    end

    # Positon of the stones
    def [](square)
      sqr = to_square(square)
      @board[sqr[0]][sqr[1]]
    end

    # Board state change

    def []=(square, player)
      sqr = to_square(square)
      adjust_stones(self[sqr], -1)
      @board[sqr[0]][sqr[1]] = player
      adjust_stones(self[sqr], +1)
    end

    # Put a new stone. Clear it if player == nil
    def put_stone(square, player)
      self[square] = player ? Stone.new(player) : nil
    end

    def clear!(square)
      put_stone(square, nil)
    end

    # Raw move
    def move!(origin, destination)
      self[destination] = self[origin]
      clear!(origin)
    end

  private
    def adjust_stones(stone, delta)
      @stones[stone.color] += delta if stone
    end
  end
end

