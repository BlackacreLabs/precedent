# encoding: utf-8
require_relative '../../../lib/precedent/load'
require 'faker'

describe Precedent do
  let(:first) { Faker::Lorem.sentence }
  let(:second) { Faker::Lorem.sentence }
  let(:third) { Faker::Lorem.sentence }

  let(:word) { Faker::Lorem.word }
  let(:another_word) { Faker::Lorem.word }

  it "compiles content" do
    input = <<-eos
#{word.capitalize}: #{first}

#{third}
    eos
    Precedent.load(input)[:content].should == [{
      :type => :flush, :number => 1, :content => third, :number => 1
    }]
  end

  context 'compiles metadata' do
    it "from a meta element" do
      input = <<-eos
#{word.capitalize}: #{first}
#{another_word.capitalize}: #{second}

#{third}
    eos
      Precedent.load(input)[:meta].should == {
        word.to_sym => first,
        another_word.to_sym => second
      }
    end
  end

  context 'injects footnotes' do
    specify {
      marker = [(1 + rand(100)).to_s, '*', "\u2020", "\u2021"].sample
      input = <<-eos
  #{first}[[#{marker}]]
#{second}

^#{marker} #{third}
      eos
      Precedent.load(input).should == {
        :meta => {},
        :content => [
          { :type => :indented,
            :number => 1,
            :content => [
              first,
              { :type => :footnote,
                :marker => marker,
                :content => {
                  :type => :indented, :content => third, :number => 1
                }
              },
              ' ' + second
            ]
          }
        ]
      }
    }
  end

  context 'problem cases' do
    specify do
      Precedent.load(
         <<-eos
Style: Board of Education v. Tom F.

@@1@@193 Fed. Appx. 26, affirmed by an equally divided Court.
        eos
      ).should == {
        :meta => { :style => 'Board of Education v. Tom F.', },
        :content => [
          { :type => :flush,
            :number => 1,
            :content => [
              { :type => :break, :page => 1 },
              "193 Fed. Appx. 26, affirmed by an equally divided Court."
            ]
          }
        ]
      }
    end

    specify do
      Precedent.load(
        <<-eos
^* A Footnote paragraph.

Another paragraph.[[*]]
        eos
      )[:content].should == [
        { :type => :flush,
          :number => 1,
          :content => [
            "Another paragraph.",
            { :type => :footnote,
              :marker => '*',
              :content => {
                :type => :indented,
                :content => 'A Footnote paragraph.',
                :number => 1
              }
            }
          ]
        }
      ]
    end

    specify do
      Precedent.load(
        <<-eos
    Quote paragraph.

Another paragraph.
        eos
      )[:content].should == [
        { :type => :quote,
          :content => [
            { :type => :flush,
              :number => 1,
              :content => "Quote paragraph." } ] },
        { :type => :flush,
          :number => 2,
          :content => 'Another paragraph.' }
      ]
    end
  end

  it "raises an error for missing footnote content" do
    expect {
      Precedent.load(
        <<-eos
Reference footnoite one.[[1]]

^2 Define footnote two.
        eos
      )
    }.to raise_error(Precedent::MissingFootnoteError)
  end
      
  it "requires metadata appear at the beginning" do
    Precedent.load(<<-eos
#{first}

#{word.capitalize}: #{second}
    eos
    )[:meta].should == {}
  end

  context 'numbering' do
    it "works with block quotations" do
      Precedent.load(<<-eos
  #{first}

      #{second}

    #{third}

#{word}
      eos
      )[:content].should == [
        { :type => :indented, :number => 1, :content => first },
        { :type => :quote,
          :content => [
            { :type => :indented, :number => 2, :content => second },
            { :type => :flush, :number => 3, :content => third }
          ]
        },
        { :type => :flush, :number => 4, :content => word },
      ]
    end

    specify {
      Precedent.numbered([
        { :type => :flush, :content => first },
        { :type => :flush, :content => second }
      ]).first.should == [
        { :type => :flush, :number => 1, :content => first },
        { :type => :flush, :number => 2, :content => second }
      ]
    }

    specify {
      Precedent.numbered({
        :type => :quote,
        :content => [
          { :type => :flush, :content => first },
          { :type => :flush, :content => second }
        ]
      }).first.should == {
        :type => :quote,
        :content => [
          { :type => :flush, :number => 1, :content => first },
          { :type => :flush, :number => 2, :content => second }
        ]
      }
    }

    specify {
      Precedent.load(
        <<-eos
#{first}[[1]]

^1 #{second}
        eos
      )[:content].should == [{
        :type => :flush,
        :number => 1,
        :content => [
          first,
          { :type => :footnote,
            :marker => '1',
            :content => {
              :type => :indented,
              :number => 1,
              :content => second
            }
          }
        ]
      }]
    }
  end
end
