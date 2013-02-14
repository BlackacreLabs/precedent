require_relative '../spec_helper'
require_relative '../../lib/precedent'
require 'faker'

describe Precedent do
  let(:first) { Faker::Lorem.sentence }
  let(:second) { Faker::Lorem.sentence }
  let(:third) { Faker::Lorem.sentence }
  let(:word) { Faker::Lorem.word }
  let(:another_word) { Faker::Lorem.word }

  it 'ignores comment lines' do
    Precedent.new("%#{first}").to_hashes[:body].should == [ ]
  end

  it 'recognizes flush and indented paragraphs' do
    Precedent.new(
      "  #{first}\n\n#{second}"
    ).to_hashes[:body].should == [
      { :type => :indented, :content => first },
      { :type => :flush, :content => second }
    ]
  end

  it 'recognizes ragged left paragraphs' do 
    Precedent.new(
      "#{first}\n\n        #{second}"
    ).to_hashes[:body].should == [
      { :type => :flush, :content => first },
      { :type => :ragged_left, :content => second }
    ]
  end

  it 'recognizes flush and indented quote paragraphs' do 
    Precedent.new(
      "    #{first}\n\n      #{second}"
    ).to_hashes[:body].should == [
      { :type => :flush_quote, :content => first },
      { :type => :indented_quote, :content => second }
    ]
  end

  it 'recognizes mixed quote and body paragraphs' do 
    Precedent.new(
      "  #{first}\n\n    #{second}"
    ).to_hashes[:body].should == [
      { :type => :indented, :content => first },
      { :type => :flush_quote, :content => second }
    ]
  end

  it "combines paragraph lines" do
    Precedent.new(
      "  #{first}\n#{second}"
    ).to_hashes[:body].should == [{
      :type => :indented,
      :content => "#{first} #{second}"
    }]
  end

  it "recognizes headings" do
    hashes = '#' * (1 + rand(3))
    Precedent.new(
      "#{hashes} #{first}"
    ).to_hashes[:body].should == [{
      :type => :heading,
      :level => hashes.length,
      :content => first
    }]
  end

    it "recognizes horizontal rules" do
      Precedent.new(<<-eos
#{first}

* * *

#{second}
      eos
      ).to_hashes[:body].should == [
        { :type => :flush,
          :content => first },
        { :type => :rule },
        { :type => :flush,
          :content => second }
      ]
    end

    it "recognizes horizontal rules within blockquotes" do
      Precedent.new(<<-eos
    #{first}

    * * *

    #{second}
      eos
      ).to_hashes[:body].should == [
        { :type => :flush_quote, :content => first },
        { :type => :rule_quote },
        { :type => :flush_quote, :content => second }
      ]
    end

    it "recognizes metadata" do
      returned = Precedent.new(<<-eos
#{word.capitalize}: #{first}
#{another_word.capitalize}: #{second}

#{third}
      eos
      ).to_hashes
      returned[:body].should == [
        {:type => :flush, :content => third }
      ]
      returned[:meta].should == {
        word.to_sym => first,
        another_word.to_sym => second
      }
    end

    it "interprets numeric metadata values" do
      num = (1 + rand(1000)).to_s
      date = (Date.today - (1 + rand(1000)))
      ['yes','true','True','Yes'].each do |truth|
        ['no', 'false', 'False', 'No'].each do |falsity|
          Precedent.new(<<-eos
#{word.capitalize}: #{num}
#{another_word.capitalize}: #{date.strftime('%Y-%m-%d')}
#{word.capitalize + another_word}: #{truth}
#{another_word.capitalize + word}: #{falsity}

#{third}
          eos
          ).to_hashes[:meta].should == {
            word.to_sym => num.to_i,
            another_word.to_sym => date,
            (word + another_word).to_sym => true,
            (another_word + word).to_sym => false
          }
        end
      end
    end

  it "recognizes footnotes" do
    [
      (1 + rand(100)).to_s,
      '*', "\u2020\u2020", "\u2020", "\u2021"
    ].each do |marker|
      returned = Precedent.new(<<-eos
#{first}

^#{marker} #{second}

^ #{third}
      eos
      ).to_hashes
      returned[:body].should == [
        { :type => :flush, :content => first }
      ]
      returned[:footnotes].should == [
        { :type => :footnote,
          :marker => marker,
          :content => second },
        { :type => :footnote, :content => third }
      ]
    end
  end

  it 'recognizes smallcaps' do
    Precedent.new(
      "  #{first} <<#{second}>> #{third}"
    ).to_hashes[:body].should == [
      { :type => :indented,
        :content => [
          first + ' ',
          { :type => :smallcaps,
            :content => second },
          ' ' + third
        ]
      }
    ]
  end

  it 'recognizes emphasis' do
    Precedent.new(
      "  #{first} \\\\#{second}\\\\ #{third}"
    ).to_hashes[:body].should == [
      { :type => :indented,
        :content => [
          first + ' ',
          { :type => :emphasis,
            :content => second },
          ' ' + third
        ]
      }
    ]
  end

  it 'recognizes citations' do
    Precedent.new(
      "#{first}{{#{second}}}#{third}"
    ).to_hashes[:body].should == [
      { :type => :flush,
        :content => [
          first,
          { :type => :citation,
            :content => second },
          third
        ]
      }
    ]
  end

  it 'preserves space around citations' do
    Precedent.new(
      "  #{first} {{#{second}}} #{third}"
    ).to_hashes[:body].should == [
      { :type => :indented,
        :content => [
          first + ' ',
          { :type => :citation,
            :content => second },
          ' ' + third
        ]
      }
    ]
  end

  it 'recognizes page breaks' do
    number = (1 + rand(1000)).to_s
    Precedent.new(
      "  #{first}@@#{number}@@#{second}"
    ).to_hashes[:body].should == [
      { :type => :indented,
        :content => [
          first, { :type => :break, :page => number.to_i }, second
        ]
      }
    ]
  end

  it 'recognizes footnote references' do
    [
      (1 + rand(100)).to_s,
      '*', "\u2020\u2020", "\u2020", "\u2021"
    ].each do |marker|
      Precedent.new(
        "#{first}[[#{marker}]]#{second}"
      ).to_hashes[:body].should == [
        { :type => :flush,
          :content => [
            first,
            { :type => :reference,
              :marker => marker },
            second
          ]
        }
      ]
    end
  end

  it 'recognizes inlines across line boundaries' do
    Precedent.new(
      "#{first} <<#{word}\n#{another_word}>> #{second}"
    ).to_hashes[:body].should == [
      { :type => :flush,
        :content => [
          first + ' ',
          { :type => :smallcaps,
            :content => "#{word} #{another_word}"
          },
          ' ' + second
        ]
      }
    ]
  end

  it 'interprets URLs as text' do
    Precedent.new(
      "A URL http://www.google.com inline."
    ).to_hashes[:body].should == [
      { :type => :flush,
        :content => 'A URL http://www.google.com inline.' }
    ]
  end

  it 'recognizes formatting within citations' do
    page = (1 + rand(1000)).to_s
    Precedent.new(
      "{{\\\\#{word}\\\\ @@#{page}@@<<#{another_word}>>}}"
    ).to_hashes[:body].should == [
      { :type => :flush,
        :content => {
          :type => :citation,
          :content => [
            { :type => :emphasis,
              :content => word },
            ' ',
            { :type => :break, :page => page.to_i },
            { :type => :smallcaps,
              :content => another_word }
          ]
        }
      }
    ]
  end
end
