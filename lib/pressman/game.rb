# We use 2 ways for denote a board square:
# As an array of board indexes, like [2,5]. Indexes are in range 0..7.
# We say this is "a square"
# As a algebraic coordinate, like "c5", analog to chess. Rows are a..h and columns are 1..8.
# We say this is "a coordinate"

module Pressman

  class Error < RuntimeError
  end

  class Game
    attr :board

    def initialize(display)
      @display = display
      @board = Board.new(display)
      @display.say 'Welcome to Pressman Game!'
    end

    def error(msg)
      Pressman::Error.new(msg)
    end

    def start(board_setup = :game)
      board.send("#{board_setup}_setup")
      board.player = Color::Black
      @winner = nil
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
          when /[a-h]\d\s*=\s*(e|b|w)/
            user_setup command  unless @winner
          when /[a-h]\d-[a-h]\d/
            move command unless @winner
          when 'r'
            resing unless @winner
          when 'e'
            start(:empty)
          when 'g'
            start(:game)
          when 'q'
            @display.say "Goodbye ..."
            return true
        end
      rescue Pressman::Error => e
        board.flash = command + " error!: #{e.message}"
      rescue Exception => e
        board.flash = command + " error!: #{e.message}" + "\n" + e.backtrace.join("\n")
      end
      board.draw
    end

    def user_setup(command)
      coord, stone = command.split('=')
      coord = coord.strip
      stone = stone.strip
      board.clear!(coord) if stone == 'e'
      board[coord] = Color::White if stone == 'w'
      board[coord] = Color::Black if stone == 'b'
    end

    def resing
      @winner = opponent
      @display.say("You resigns")
      @display.say("#{Color.to_s(@winner)} player wins!!")
    end

    def move(move)
      squares = move.is_a?(String) ? parse_move(move) : move

      validate_move(squares)

      board.kill_stone squares[1]
      board[squares[1]] = board[squares[0]]
      board.clear!(squares[0])

      check_regeneration(squares[1])
      check_reactivation(squares[1])

      check_winner
      next_player
    end

  private

    def parse_move(text)
      text.split('-').map{|coord| coord.to_square}
    end

    def next_player
      board.player = board.oponent
    end

    def validate_move(squares)
      raise error("You don't have a stone in #{squares[0].to_coord}") unless board.friend_stone?(squares[0])

      delta = squares[1].subs squares[0]
      # can move along rows or columns. In this case or row not change or column not change
      is_straight = (delta[1]*delta[0] == 0)
      # can move along diagonals. In this case the change rate rows / columns == 1
      is_diagonal = (delta[0] != 0) && ((delta[1] / delta[0]).abs == 1)

      raise error("Invalid move") unless (is_straight ||  is_diagonal)

      occupied = first_between(squares, :is_occupied?)
      occupied = squares[1] if board.friend_stone?(squares[1])
      raise error("Square #{occupied.to_coord} is occupied") if occupied
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
      board.put_stone(free_square)
    end

    def check_reactivation(square)
      board.activate_stone(square) if board.stone_at_side?(square)
    end

    def check_winner
      return if stone_count[Color.to_ord(oponent)] > 0
      @winner = player
      @display.say("#{Color.to_s(@winner)} player wins!!")
    end
  end
end

