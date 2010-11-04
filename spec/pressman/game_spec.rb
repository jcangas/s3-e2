
require 'spec_helper'
module Pressman
  describe Game do
    let(:display) {double('display ').as_null_object }
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
        game.stones.should == [16, 16]
      end
    end

    describe "when player try" do
      context "a invalid move" do
        it "it is refused if origin empty" do
          game.start
          expect {  game.move("c1-b5")}.to raise_error(RuntimeError, "You don't have a stone in c1")
        end

        it "it is refused if target occupied" do
          game.start
          expect {  game.move("g2-g3")}.to raise_error(RuntimeError, "Square g3 is occupied")
        end
      end

      context "a valid move" do
        it "the player stone is moved" do
          game.start
          old_stones = game.stones.dup
          game.board['g5'].should == game.player
          game.board.is_empty?('c5').should be_true
          game.move("g5-c5")
          game.board.is_empty?('g5').should be_true
          game.board['c5'].should == game.player
          game.stones.should == old_stones
        end

        it "kill a stone if target square is not free" do
          game.start

          old_stones = game.stones.dup
          game.board['g5'].should == game.player
          game.board['b5'].should == game.oponent
          game.move("g5-b5")
          game.board.is_empty?('g5').should be_true
          game.board['b5'].should == game.player
          old_stones[Color.to_ord(game.oponent)] -= 1
          game.stones.should == old_stones
        end
      end

    end
  end
end

