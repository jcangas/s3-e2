
module Pressman

  class Error < RuntimeError
  end

  # Game act as controller, it query and change board's state enforicing game rules.

  class Game
    include Pressman::Vector

    attr_accessor :gui
    attr :board
    attr :winner

    def initialize
      @board = Board.new(8,8)
    end

    def error(msg)
      Pressman::Error.new(msg)
    end

    def start(template = :game)
      board_setup(template)
      board.player = :black
      @winner = nil
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

    def resing
      @winner = oponent
    end

    def next_player
      board.player = board.oponent
    end

    def put_stone(square, player)
      board.put_stone(square, player)
    end


    # Here we can apply Observer Pattern to extract the logic for the rule games
    # class GameRules
    #   def before_move
    #     validate_move!
    #     ...
    #   end
    #
    #   def after_move
    #     if can_regenerate?(squares[1])
    #     ...
    #   end
    #
    # end
    #
    # So, at game creation: board.add_observer(GameRules.new)
    #
    # But not sure if this worth for Pressman :)
    def move(move)
      squares = move.is_a?(String) ? parse_move(move) : move

      validate_move!(squares)

      board.move!(squares[0], squares[1])

      if can_regenerate?(squares[1])

        regenerate_at = input_regenerate_at

        board[squares[1]].deactivate
        board.put_stone(regenerate_at, player) if regenerate_at

      else
        check_reactivation(squares[1])
      end
      check_for_winner
      next_player
    end

    def validate_move!(squares)
      raise error("You don't have a stone in #{board.to_coord(squares[0])}") unless board.friend?(squares[0])

      delta = vector_subs(squares[1], squares[0])
      # can move along rows or columns. In this case or row not change or column not change
      is_straight = (delta[1]*delta[0] == 0)
      # can move along diagonals. In this case rows / columns == 1
      is_diagonal = (delta[0] != 0) && ((delta[1] / delta[0]).abs == 1)

      raise error("Invalid move") unless (is_straight ||  is_diagonal)

      occupied = first_occupied(squares[0], squares[1])
      occupied = squares[1] if board.friend?(squares[1])
      raise error("Square #{board.to_coord( occupied)} is occupied") if occupied
    end

    def can_regenerate?(square)
      # check stone is at their top and active
      if board.at_top?(square, player) && board[square].active?
        free_square = first_free_at_bottom
      end
    end

    def check_reactivation(square)
      board[square].activate if board.at_home?(square)
    end

    def check_for_winner
      @winner = player if stones[oponent] == 0
    end

    def first_occupied(first_sqr, last_sqr)
      first_between(first_sqr, last_sqr, :is_occupied?)
    end

     # Returns free square at player's bottom
    def first_free_at_bottom
      bottom_first = [board.bottom(player), 0]
      bottom_last =  [board.bottom(player), board.max_column]
      first_between(bottom_first, bottom_last, :is_empty?, :inclusive)
    end

  private # some helpers

    def parse_move(text)
      text.split('-').map{|coord| board.to_square(coord)}
    end

    def input_regenerate_at
      gui.say "column for regenration?"
      col = gui.get_column
      [board.bottom(player), col]
    end

    # find first square that satisfy condition, along the path first_sqr ... last_sqr
    def first_between(first_sqr, last_sqr, condition, inclusive = nil)
      step = vector_subs(last_sqr, first_sqr).map {|c| c <=> 0 } # map to signum
      checked = first_sqr
      checked = vector_sum(checked, step) if !inclusive
      while checked != last_sqr
        return checked if board.send(condition, checked)
        checked = vector_sum(checked, step)
      end
      return checked if inclusive && board.send(condition, checked)
      nil
    end

    # A simple strategy for allow multiple board setups.
    # This could be extended to reload a game play ...

    def board_setup(template)
      send("#{template}_setup")
    end

    def empty_setup
      for row in 0..board.max_row do
        for col in 0..board.max_column do
          board.clear!([row, col])
        end
      end
    end

    def game_setup
      for row in 0..board.max_row do
          case row
            when (0..1)
               color = :white
            when  (6..board.max_row)
               color = :black
            else
              color = nil
          end
        for col in 0..board.max_column do
          board.put_stone([row, col], color)
        end
      end
    end
  end
end

