require_relative 'parser'

module Precedent
  class Translator
    @@parser = Parser.new

    def initialize(input)
      @input = input
    end

    def to_hashes
      raw_parser_output
    end

    private

    def raw_parser_output
      return @raw if @raw
      @raw = @@parser.parse(@input)
    end
  end
end
