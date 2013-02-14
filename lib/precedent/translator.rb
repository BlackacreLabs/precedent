module Precedent
  class Translator
    @@parser = DocumentParser.new

    def initialize(input)
      @input = input
    end

    def to_hashes
      raw_parser_output
    end

    private

    def raw_parser_output
      return @raw if @raw
      tree = @@parser.parse(@input)
      if tree.nil?
        raise Exception,
          "Parse error at offset: #{@@parser.index} " +
          "#{@@parser.failure_reason}"
      end
      @raw = tree.build
    end
  end
end
