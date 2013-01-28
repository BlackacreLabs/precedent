require_relative '../../../lib/precedent/parse'
require 'faker'
require 'ap'
include Precedent

describe Precedent do
  context 'block elements' do
    let(:first) { Faker::Lorem.sentence }
    let(:second) { Faker::Lorem.sentence }
    let(:third) { Faker::Lorem.sentence }
    let(:word) { Faker::Lorem.word }
    let(:another_word) { Faker::Lorem.word }

    specify {
      Precedent.parse("  #{first}\n\n#{second}").should == [
        { :type => :indented, :content => first },
        { :type => :flush, :content => second }
      ]
    }

    specify { 
      Precedent.parse("  #{first}\n\n      #{second}").should == [
        { :type => :indented, :content => first },
        { :type => :indented_quote, :content => second }
      ]
    }

    specify { 
      Precedent.parse("  #{first}\n\n    #{second}").should == [
        { :type => :indented, :content => first },
        { :type => :quote, :content => second }
      ]
    }

    it "combines paragraph lines" do
      Precedent.parse("  #{first}\n#{second}").should == [{
        :type => :indented, :content => "#{first} #{second}"
      }]
    end

    it "recognizes headings" do
      hashes = '#' * (1 + rand(3))
      Precedent.parse("#{hashes} #{first}").should == [{
        :type => :heading,
        :level => hashes.length,
        :content => first
      }]
    end

    it "recognizes metadata" do
      Precedent.parse(<<-eos
#{word.capitalize}: #{first}
#{another_word.capitalize}: #{second}

  #{third}
      eos
      ).should == [
        {
          :type => :meta,
          :content => {
            word.capitalize.to_sym => first,
            another_word.capitalize.to_sym => second
          }
        },
        {:type => :indented, :content => third }
      ]
    end
  end
end
