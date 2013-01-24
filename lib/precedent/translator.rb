module Precedent
  class Translator
    def initialize text
      @text = text
    end

    def paragraph_type text
      if /^\^(\d+) / =~ text
        :footnote
      else
        :paragraph
      end
    end

    def paragraph_format text
      if /^( +)/ =~ text
        case $1.length
        when 2
          :indented
        when 4
          :flush_quote
        when 6
          :indented_quote
        else
          raise "Bad indentation:\n#{text}"
        end
      else
        :flush
      end
    end

    def parse_paragraphs
      @text.split(/\n{2,}/).map do |chunk|
        text = chunk.gsub("\n", ' ')
        {
          :type => paragraph_type(text),
          :format => paragraph_format(text),
          :text => text
        }
      end
    end

    def to_hash
      parse_paragraphs
    end
  end
end
