require_relative '../../../lib/precedent/parse'
require 'faker'
include Precedent

describe Precedent do
  let(:first) { Faker::Lorem.sentence }
  let(:second) { Faker::Lorem.sentence }
  let(:third) { Faker::Lorem.sentence }
  let(:word) { Faker::Lorem.word }
  let(:another_word) { Faker::Lorem.word }

  context 'block elements' do
    it "ignores comment lines" do
      Precedent.parse("%#{first}").should == [
        { :type => :comment, :content => first }
      ]
    end

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
      Precedent.parse("#{first}\n\n        #{second}").should == [
        { :type => :flush, :content => first },
        { :type => :ragged_left, :content => second }
      ]
    }

    specify { 
      Precedent.parse("    #{first}\n\n      #{second}").should == [
        { :type => :quote,
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
          { :type => :meta,
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
        ['yes','true','True','Yes'].each do |truth|
          ['no', 'false', 'False', 'No'].each do |falsity|
            Precedent.parse(<<-eos
#{word.capitalize}: #{num}
#{another_word.capitalize}: #{date.strftime('%Y-%m-%d')}
#{word.capitalize + another_word}: #{truth}
#{another_word.capitalize + word}: #{falsity}

#{third}
            eos
            ).should == [
                { :type => :meta,
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
      end
    end

    context 'footnotes' do
      it "parses footnotes" do
        [(1 + rand(100)).to_s, '*', "\u2020", "\u2021"].each do |marker|
          Precedent.parse(<<-eos
^#{marker} #{first}
#{second}

^ #{third}
          eos
          ).should == [
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

  context 'inline elements' do
    it 'parses smallcaps' do
      Precedent.parse("  #{first} <<#{second}>> #{third}").should == [
        { :type => :indented,
          :content => [
            first + ' ',
            { :type => :smallcaps, :content => second },
            ' ' + third
          ]
        }
      ]
    end

    it 'parses emphasis' do
      Precedent.parse("  #{first} //#{second}// #{third}").should == [
        { :type => :indented,
          :content => [
            first + ' ',
            { :type => :emphasis, :content => second },
            ' ' + third
          ]
        }
      ]
    end

    it 'parses citations' do
      Precedent.parse("  #{first} {{#{second}}} #{third}").should == [
        { :type => :indented,
          :content => [
            first + ' ',
            { :type => :citation, :content => second },
            ' ' + third
          ]
        }
      ]
    end

    it 'parses page breaks' do
      number = (1 + rand(1000)).to_s
      Precedent.parse("  #{first}@@#{number}@@#{second}").should == [
        { :type => :indented,
          :content => [
            first, { :type => :break, :page => number.to_i }, second
          ]
        }
      ]
    end

    it 'parses footnote references' do
      [(1 + rand(100)).to_s, '*', "\u2020", "\u2021"].each do |marker|
        Precedent.parse("  #{first}[[#{marker}]]#{second}").should == [
          { :type => :indented,
            :content => [
              first, { :type => :reference, :marker => marker }, second
            ]
          }
        ]
      end
    end
  end
end
