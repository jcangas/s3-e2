
# I know is good practice spec folder mimics lib folder structure
#
#
#

require 'spec_helper'
module Pressman
  describe Game do
    let(:game) do
      game = Game.new
      game.stub!(:input_regenerate_at).and_return {game.first_free_at_bottom}
      game
    end

    describe "start" do
      it "White begin as oponent" do
        game.start
        game.oponent.should == :white
      end

      it "Black starts the game" do
        game.start
        game.player.should == :black
      end

      it "Stones count is ok" do
        game.start
        game.stones.should == {:white => 16, :black => 16}
      end
    end

    describe "Game Over" do
      it "player loses if all their stones are captured" do
        # board setup for test
        game.start :empty
        game.put_stone("h4", :black)
        game.put_stone("a4", :white)

        game.move "h4-a4"
        game.winner.should == :black
      end

    end

    describe "playing" do
      context "an invalid move" do
        before(:each) {game.start}
        it "is refused if origin empty" do
          expect {  game.move("c1-b5")}.to raise_error(RuntimeError, "You don't have a stone in c1")
        end

        it "is refused if target occupied by oponent" do
          expect {  game.move("g2-g3")}.to raise_error(RuntimeError, "Square g3 is occupied")
        end

        it "is refused if path occupied by a fiend stone" do
          game.put_stone("d2", game.player)
          expect {  game.move("g5-c1") }.to raise_error(RuntimeError, "Square d2 is occupied")
        end

        it "is refused if path occupied by an oponent stone" do
          game.put_stone("d2", game.oponent)
          expect {  game.move("g2-c2")}.to raise_error(RuntimeError, "Square d2 is occupied")
        end
      end

      context "after a valid move" do
        it "player turn change" do
          game.start
          player = game.player
          game.move("g5-c5")
          game.oponent.should == player
        end

        it "their stone is moved" do
          game.start
          player = game.player
          game.move("g5-c5")
          game.board.is_empty?('g5').should be_true
          game.board.occupied_by?('c5', player).should be_true
        end

        it "stone count not change if no caputre" do
          game.start
          old_stones = game.stones.dup
          game.move("g5-c5")
          game.stones.should == old_stones
        end

        it "kill a stone if target square is not free" do
          game.start
          old_stones = game.stones.dup
          player = game.player
          oponent = game.oponent
          game.move("g5-b5")
          game.stones[player].should == old_stones[player]
          game.stones[oponent].should == old_stones[oponent] - 1
        end
      end
    end

    context "regeneration" do
      before(:each) do
        game.start :empty
        game.put_stone "h4", game.player
      end

      it "generate a stone when player move to top" do
        old_stones = game.stones.dup
        player = game.player
        oponent = game.oponent
        game.move("h4-a4")
        # the generated stone goes at first free square in bottom row
        game.board.is_occupied?("h1").should be_true
        game.stones[oponent].should == old_stones[oponent]
        game.stones[player].should == old_stones[player] + 1
      end

      it "Stone is deactivated when move to top" do
        game.move("h4-a4")
        game.board["a4"].active?.should be_false
      end

      it "Stone deactivation is mantained if not cross side" do
        game.stub(:next_player)

        # force deactivation
        game.move("h4-a4")

        game.move("a4-c4")
        game.board["c4"].active?.should be_false

      end

      it "Stone is reactivated when move to their side" do
        game.stub(:next_player)

        # force deactivation
        game.move("h4-a4")


        # check reactivation is mantained if cross side
        game.move("a4-e4")
        game.board["e4"].active?.should be_true
      end
    end
  end
end

