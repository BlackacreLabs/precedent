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

    def to_indexable_record
      hashes = to_hashes
      combined_blocks = to_hashes[:body] + to_hashes[:footnotes]
      ret = {
        :text => combined_blocks.map { |x| just_content(x) }.join("\n\n"),
        :blocks => combined_blocks.map do |x|
          hash = hash_without(x, :content)
          if hash.keys.count == 1
            hash[:type]
          else
            [hash[:type], hash_without(hash, :type)]
          end
        end,
        :formatting => combined_blocks.map do |b|
          hash = hash_without(inline_offsets(b), :offset)
          hash.empty? ? nil : hash
        end
      }
      ret
    end

    def inline_offsets(object, inlines=nil)
      inlines ||= { :offset => 0 }
      case object
      when Hash
        if object[:content]
          if [:emphasis, :smallcaps, :citation].include?(object[:type])
            # FIXME: Inefficient hack
            inner_content = just_content(object)
            inlines[object[:type]] ||= []
            inlines[object[:type]] << [inlines[:offset], inlines[:offset] + inner_content.length]
            inline_offsets(object[:content], inlines)
          else
            inline_offsets(object[:content], inlines)
          end
        elsif object[:type] == :break
          inlines[:breaks] ||= {}
          inlines[:breaks][inlines[:offset]] = object[:page]
          inlines
        else
          inlines
        end
      when Array
        object.reduce(inlines) do |mem, o|
          inline_offsets(o, mem)
        end
      when String
        inlines.merge(offset: inlines[:offset] + object.length)
      end
    end

    def just_content(object)
      case object
      when Hash
        just_content(object[:content]) if object[:content]
      when Array
        object.map {|x| just_content(x) }.join
      when String
        object
      end
    end

    private

    def hash_without(hash, key)
      ret = hash.dup
      ret.delete key
      ret
    end

    def raw_parser_output
      return @raw if @raw
      @raw = @@parser.parse(@input)
    end
  end
end
