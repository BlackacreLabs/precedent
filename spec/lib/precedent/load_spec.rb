# encoding: utf-8
require_relative '../../../lib/precedent/load'
require 'faker'
include Precedent

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
      :type => :flush, :content => third
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
        word.capitalize.to_sym => first,
        another_word.capitalize.to_sym => second
      }
    end

    it "from multiple meta elements" do
      input = <<-eos
#{word.capitalize}: #{first}

#{third}

#{another_word.capitalize}: #{second}
    eos
      Precedent.load(input)[:meta].should == {
        word.capitalize.to_sym => first,
        another_word.capitalize.to_sym => second
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
            :content => [
              first,
              { :type => :footnote,
                :marker => marker,
                :content => [
                  { :type => :indented, :content => third }
                ]
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
        :meta => { :Style => 'Board of Education v. Tom F.', },
        :content => [
          { :type => :flush,
            :content => [
              { :type => :break, :page => 1 },
              "193 Fed. Appx. 26, affirmed by an equally divided Court."
            ]
          }
        ]
      }
    end
  end
end
