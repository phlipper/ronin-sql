require 'spec_helper'
require 'sql/statement_examples'
require 'ronin/sql/statement'
require 'ronin/sql/statements'

describe SQL::Statements do
  subject { Object.new.extend(described_class) }

  describe "#statement" do
    let(:keyword) { :EXEC }

    it "should create an arbitrary statement" do
      subject.statement(keyword).keyword.should == keyword
    end
  end

  include_examples "Statement", :select, :SELECT, [1,2,3,:id]
  include_examples "Statement", :insert, :INSERT
  include_examples "Statement", :update, :UPDATE, :table
  include_examples "Statement", :delete, [:DELETE, :FROM], :table
  include_examples "Statement", :drop_table, [:DROP, :TABLE], :table
end
