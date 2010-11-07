module Pressman

  # A simple GUI for Pressman game.
  # Currently only 8x8 board are supported

  class GameUI
    COLUMN_LABELS = '   1   2   3   4   5   6   7   8'
    ROW_LABELS  = "abcdefgh"
    ROW_SEP =  '  ' + "-" * (4*8)

    attr_reader :game

    def get_square_icon(row, col)
      stone = game.board[[row, col]]
      if stone
        icon = {:white => 'o', :black => 'x'}[stone.color]
        icon = icon.upcase if stone.inactive?
      else
        icon = ' '
      end
      icon
    end

    def initialize(game)
      @game = game
      game.gui = self
    end

    def draw_board
      say "#{Time.now}"
      say COLUMN_LABELS
      for row in 0..7 do
        row_draw = []
        for col in 0..7 do
          row_draw << get_square_icon(row, col)
        end
        say ROW_SEP
        say "#{ROW_LABELS[row]}| #{row_draw.join(' | ')} |"
      end
      say ROW_SEP
      say "Stones: " + game.stones.map { |k, v|  "#{k.capitalize} = #{v}"}.join('  ')
      say "#{@flash}" if @flash
      @flash = nil
      say "#{game.player.capitalize} move?"
    end

    def say(*args)
      puts(*args)
    end

    def get_column
      result = nil
      while !result
        txt = gets.chomp
        case txt
          when /[1-9]/
            result = txt.to_i
        end
      end
      result - 1
    end

    def terminate
      if game.winner
        say("#{game.winner.capitalize} player wins!!")
        @terminate = true
      end
      @terminate
    end

    def run
      say 'Welcome to Pressman Game!'
      game.start
      while not terminate
        draw_board
        input(gets.chomp)
      end
    end

    def input(command)
      begin
        case command
          when /[a-h]\d\s*=\s*(e|b|w)/
            coord, stone = command.split('=').map {|s| s.strip}
            color = {'e' => nil, 'w' => :white, 'b' => :black}[stone]
            game.put_stone(coord, color)

          when /([a-h]\d)-([a-h]\d)/
            game.move command
            @flash = "Moved #{$1} to #{$2}"

          when 'r'
            say("You resigns")
            game.resing

          when 'e'
            game.start(:empty)

          when 'g'
            game.start(:game)

          when 'q'
            say "Goodbye ..."
            @terminate = true
        end

      rescue Pressman::Error => e
        @flash = command + " error!: #{e.message}"

      rescue Exception => e
        @flash = command + " error!: #{e.message}" + "\n" + e.backtrace.join("\n")
      end
    end
  end
end

