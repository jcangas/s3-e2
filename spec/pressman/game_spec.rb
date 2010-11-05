
require 'spec_helper'
module Pressman
  describe Game do
    let(:display) {double('display').as_null_object }
    let(:game) {game = Game.new(display); game.board.stub(:draw); game}

    describe "at start" do
      it "sends a welcome message" do
        display.should_receive(:say).with('Welcome to Pressman Game!')
        game.start
      end

      it "White begin as oponent" do
        game.start
        game.oponent.should == Color::White
      end

      it "Black starts the game" do
        game.start
        game.player.should == Color::Black
      end

      it "Stones count is ok" do
        game.start
        game.stone_count.should == [32, 16, 16]
      end
    end

    describe "Game Over" do
      it "player loses if all their stones are captured" do
        game.start :empty
        game.board["h4"] = Color::Black
        game.board["a4"] = Color::White

        display.should_receive(:say).with('Black player wins!!')

        game.move "h4-a4"
        game.stone_count.should == [62, 0, 2]
      end
    end

    describe "when player try" do
      context "an invalid move" do
        before(:each) {game.start}
        it "is refused if origin empty" do
          expect {  game.move("c1-b5")}.to raise_error(RuntimeError, "You don't have a stone in c1")
        end

        it "is refused if target occupied" do
          expect {  game.move("g2-g3")}.to raise_error(RuntimeError, "Square g3 is occupied")
        end

        it "is refused if path occupied by a fiend stone" do
          game.board["d2"] = game.player
          expect {  game.move("g5-c1")}.to raise_error(RuntimeError, "Square d2 is occupied")
        end

        it "is refused if path occupied by an oponent stone" do
          game.board["d2"] = game.oponent
          expect {  game.move("g2-c2")}.to raise_error(RuntimeError, "Square d2 is occupied")
        end
      end

      context "a valid move" do
        it "their stone is moved" do
          game.start
          old_stones = game.stone_count.dup
          player = game.player
          game.board.occupied_by?('g5', player).should be_true
          game.board.is_empty?('c5').should be_true
          game.move("g5-c5")
          game.board.is_empty?('g5').should be_true
          game.board.occupied_by?('c5', player).should be_true
          game.stone_count.should == old_stones
        end

        it "kill a stone if target square is not free" do
          game.start
          old_stones = game.stone_count.dup
          player = game.player
          game.board.occupied_by?('g5', player).should be_true
          game.board.occupied_by?('b5', game.oponent).should be_true
          game.move("g5-b5")
          game.board.is_empty?('g5').should be_true
          game.board.occupied_by?('b5', player).should be_true
          game.stone_count.subs(old_stones).should == [1, -1, 0]
        end
      end

    end
  end
end

