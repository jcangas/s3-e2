
require 'spec_helper'
module Pressman
  describe Game do
    let(:display) {double('display').as_null_object }
    let(:game) {game = Game.new(display); game.board.stub(:draw); game}

    context "regeneration" do
      before(:each) do
        game.start :empty
        game.board.put_stone "h4"
      end

      it "generate a stone when player move to top" do
        old_stones = game.stone_count.dup
        game.move("h4-a4")
        # the generated stone goes at first free square in bottom row
        game.board.is_occupied?("h1").should be_true
        game.stone_count.subs(old_stones).should == [-1, 0, 1]
      end

      it "Stone is deactivated when move to top" do
        old_count = game.stone_count.dup
        game.move("h4-a4")
        game.board.stone_activated?("a4").should be_false
      end

      it "Stone is reactivated when move to their side" do
        game.stub(:next_player)

        # force deactivation
        game.move("h4-a4")

        # check deactivation is mantained if not cross side
        game.move("a4-c4")
        game.board.stone_activated?("c4").should be_false

        # check reactivation is mantained if cross side
        game.move("c4-e4")
        game.board.stone_activated?("e4").should be_true
      end
    end
  end
end

