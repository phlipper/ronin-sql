require 'spec_helper'

require 'ronin/sql/formatter'

describe SQL::Formatter do
  describe "#null" do
    it "should return the NULL keyword" do
      subject.null.should == 'null'
    end
  end

  describe "#boolean" do
    it "should format a true value" do
      subject.boolean(true).should == 'true'
    end

    it "should format a false value" do
      subject.boolean(false).should == 'false'
    end
  end

  describe "#integer" do
    it "should format an Integer" do
      subject.integer(10).should == '10'
    end
  end

  describe "#float" do
    it "should format a Float" do
      subject.float(0.5).should == '0.5'
    end
  end

  describe "#keyword" do
    it "should preserve case when encoding keywords by default" do
      subject.keyword(:Select).should == 'Select'
    end

    context "with lower-case" do
      subject { described_class.new(:case => :lower) }

      it "should allow encoding keywords in upper-case" do
        subject.keyword(:ID).should == 'id'
      end
    end

    context "with upper-case" do
      subject { described_class.new(:case => :upper) }

      it "should allow encoding keywords in upper-case" do
        subject.keyword(:id).should == 'ID'
      end
    end

    context "with random-case" do
      subject { described_class.new(:case => :random) }

      it "should allow encoding keywords in random-case" do
        subject.keyword(:select).should_not == 'select'
      end
    end
  end

  describe "#string" do
    let(:text) { 'hello' }

    it "should single-quote strings by default" do
      subject.string(text).should == "'hello'"
    end

    context "with double quotes" do
      subject { described_class.new(:quotes => :double) }

      it "should allow double-quoting strings" do
        subject.string(text).should == '"hello"'
      end
    end

    context "with hex_escape" do
      subject { described_class.new(:hex_escape => true) }

      it "should allow hex-escaping strings" do
        subject.string(text).should == "hex(0x68656c6c6f)"
      end
    end
  end

  describe "#list" do
    let(:list) { [1,2,3] }

    it "should format an empty Array" do
      subject.list().should == "()"
    end

    it "should format a singleton Array" do
      subject.list(1).should == "(1)"
    end

    it "should parenthesis all lists by default" do
      subject.list(*list).should == "(1,2,3)"
    end

    context "with less parenthesis" do
      subject { described_class.new(:parens => :less) }

      it "should allow omitting parenthesis on non-singleton lists" do
        subject.list(*list).should == "1,2,3"
      end

      it "should keep parenthesis on empty lists" do
        subject.list().should == "()"
      end
    end
  end

  describe "#hash" do
    it "should format an empty Hash" do
      subject.hash({}).should == "()"
    end

    it "should format a singleton Hash" do
      subject.hash({:count => 5}).should == "(count=5)"
    end

    it "should format a single Hash" do
      update = {:user => 'bob', :password => 'lol'}

      subject.hash(update)[1..-2].split(',').should =~ [
        "user='bob'",
        "password='lol'"
      ]
    end
  end

  describe "#join" do
    let(:fragments) { [:union, :select] }

    it "should space-separate elements by default" do
      subject.join(*fragments).should == "union select"
    end

    context "without spaces" do
      subject { described_class.new(:space => false) }

      it "should allow comment-separated joining of elements" do
        subject.join(*fragments).should == "union/**/select"
      end
    end
  end

  describe "#format_elements" do
    it "should format multiple tokens" do
      subject.format_elements(1, :eq, 1).should == '1 = 1'
    end
  end
end
