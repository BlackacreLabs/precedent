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
        { :type => :quote, :content => [ { :type => :indented, :content => second } ] }
      ]
    }

    specify { 
      Precedent.parse("    #{first}\n\n      #{second}").should == [
        {
          :type => :quote,
          :content => [
            { :type => :flush, :content => first },
            { :type => :indented, :content => second }
          ]
        }
      ]
    }

    specify { 
      Precedent.parse("  #{first}\n\n    #{second}").should == [
        { :type => :indented, :content => first },
        { :type => :quote, :content => [ { :type => :flush, :content => second } ] }
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

    context "rules" do
      it "parses horizontal rules" do
        Precedent.parse(<<-eos
#{first}

* * *

#{second}
        eos
        ).should == [
          { :type => :flush, :content => first },
          { :type => :rule },
          { :type => :flush, :content => second }
        ]
      end

      it "parses horizontal rules within blockquotes" do
        Precedent.parse(<<-eos
    #{first}

    * * *

    #{second}
        eos
        ).should == [
          { :type => :quote,
            :content => [
              { :type => :flush, :content => first },
              { :type => :rule },
              { :type => :flush, :content => second }
            ]
          }
        ]
      end
    end

    context 'metadata' do
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
          {:type => :flush, :content => third }
        ]
      end

      it "casts metadata" do
        num = (1 + rand(1000)).to_s
        date = (Date.today - (1 + rand(1000)))
        truth = ['yes','true','True','Yes'].sample
        falsity = ['no', 'false', 'False', 'No'].sample
        Precedent.parse(<<-eos
#{word.capitalize}: #{num}
#{another_word.capitalize}: #{date.strftime('%Y-%m-%d')}
#{word.capitalize + another_word}: #{truth}
#{another_word.capitalize + word}: #{falsity}

#{third}
        eos
        ).should == [
            {
              :type => :meta,
              :content => {
                word.capitalize.to_sym => num.to_i,
                another_word.capitalize.to_sym => date,
                (word.capitalize + another_word).to_sym => true,
                (another_word.capitalize + word).to_sym => false
              }
            },
            {:type => :flush, :content => third }
          ]
      end
    end


    context 'footnotes' do
      it "parses footnotes" do
        marker = [(1 + rand(100)).to_s, '*', "\u2020", "\u2021"].sample
        input = <<-eos
^#{marker} #{first}
#{second}

^ #{third}
        eos
        Precedent.parse(input).should == [
          { :type => :footnote,
            :marker => marker,
            :content => [
              { :type => :indented, :content => "#{first} #{second}" },
              { :type => :indented, :content => third }
            ]
          }
        ]
      end
    end

  end
end
