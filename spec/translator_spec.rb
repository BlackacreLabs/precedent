require_relative '../lib/precedent/translator'
require 'rubygems'
require 'faker'

include Precedent
include Faker


def par text
  { :paragraph => [ text ] }
end

describe Translator do
  context 'block-level elements' do
    it "translates simple paragraphs" do
      sentence = Lorem.sentence
      Translator.new(sentence).to_hash.first[:text].should == sentence
    end

    it "differentiate flush and indented paragraphs" do
      res = Translator.new("  #{Lorem.sentence}\n\n#{Lorem.sentence}").to_hash
      res.first[:format].should == :indented
      res[1][:format].should == :flush
    end

    context "footnotes" do
      it "detects footnotes" do
        r = Translator.new(
          <<-eos
^#{1 + rand(50)} #{Lorem.sentence}
#{Lorem.sentence}
          eos
        ).to_hash
        r.first[:type].should == :footnote
      end

      it "combines subsequent paragraphs", :focus => true do 
        r = Translator.new(
          <<-eos
^#{1 + rand(50)} #{Lorem.sentence}
#{Lorem.sentence}

  #{Lorem.sentence}
          eos
        ).to_hash
        r.first[:type].should == :footnote
        r.first[:children].count.should == 2
      end
    end

    it "differentiates flush and indented blockquote paragraphs" do
      r = Translator.new(
        <<-eos
      #{Lorem.words(5)}
    #{Lorem.words(5)}
    #{Lorem.words(5)}

    #{Lorem.words(5)}
    #{Lorem.words(5)}
    #{Lorem.words(5)}
        eos
      ).to_hash
      r.first[:format].should == :indented_quote
      r.last[:format].should == :flush_quote
    end

    it "raises an error for incorrectly indented text" do
      lambda {
        Translator.new(" #{Lorem.sentence}").to_hash
      }.should raise_error
    end

    context 'lines' do 
      let(:first) { Lorem.sentence }
      let(:second) { Lorem.sentence }
      let(:third) { Lorem.sentence }

      it 'separates paragraphs separated by blanks lines' do
        blanks = "\n" * (2 + rand(10))
        r = Translator.new("#{first}#{blanks}#{second}").to_hash
        r.first[:text].should == first
        r.first[:type].should == :paragraph
        r.last[:text].should == second
        r.last[:type].should == :paragraph
      end

      it "joins lines separated by newlines" do
        sentences = Lorem.sentences(3 + rand(5))
        r = Translator.new(sentences.join("\n")).to_hash
        r.first[:text].should == sentences.join(' ')
      end
    end
  end
end
