require 'spec_helper'
module Pressman
  describe Board do
    let(:board) { Board.new(8,8) }

    it "is created ok" do
      board.max_row.should == 7
      board.max_column.should == 7
      board.stones.should == {:white => 0, :black => 0}
    end

    context "adding a stone" do
      before(:each) { board.put_stone("c3", :black) }

      it "change the sqaure state" do
        board["c3"].color.should == :black
      end

      it "stone counts are adjusted" do
        board.stones.should == {:white => 0, :black => 1}
      end
    end

    context "clearing a square" do
      before(:each) { board.put_stone("c3", :black) }

      it "at occupied square" do
        board.clear!("c3")
        board["c3"].should == nil
      end

      it "stone counts are adjusted" do
        board.clear!("c3")
        board.stones.should == {:white => 0, :black => 0}
      end
    end

    context "moving a stone" do
      before(:each) {
        board.put_stone("c3", :black)
        board.put_stone("d4", :white)
        board.move!("c3","d4")
      }

      it "source square is cleared" do
        board["c3"].should == nil
      end

      it "target square is occupied" do
        board["d4"].color.should == :black
      end

      it "stone counts are adjusted" do
        board.stones.should == {:white => 0, :black => 1}
      end
    end
  end
end

