# encoding: UTF-8

require_relative 'grammar/node_patch'
require_relative 'grammar/inline'

module Precedent
  class Parser
    # cached instance of the parser for inline elements
    @@inline_parser = InlineParser.new

    def parse(input)
      post_process(parse_blocks(input))
    end

    def post_process(raw_hash)
      raw_blocks = raw_hash.delete(:blocks)
      document_blocks = raw_blocks.reduce(
        body: [], footnotes: []
      ) do |mem, block|
        content = block[:content]
        if content
          ast = @@inline_parser.parse(content.join(' ').gsub(/ +/, ' '))
          block.merge!(content: ast.build)
        end

        type = block[:type]
        if type == :footnote
          mem[:footnotes] << block
        else
          mem[:body] << block
        end
        mem
      end
      raw_hash.merge(document_blocks)
    end

    def build_block(type, first_content=nil)
      if first_content
        { :type => type, :content => [first_content] }
      else
        { :type => type }
      end
    end

    BLANK_LINE = /^\s*$/
    COMMENT_LINE = /^%/
    FLUSH_LINE = /^([^ ].+)$/
    FLUSH_QUOTE = /^    (.+)$/
    FOOTNOTE_CONTINUE = /^\^\s+(.+)$/
    FOOTNOTE_START = /^\^([^ ]+)\s+(.+)$/
    HEADING = /^(#+)\s+(.+)$/
    INDENTED = /^  (.+)$/
    INDENTED_QUOTE = /^      (.+)$/
    METADATA = /^([A-Z][[:ascii:]]*): (.+)$/
    RAGGED_LEFT = /^        (.+)$/
    RULE_BODY = /^\* \* \*\s*$/
    RULE_QUOTE = /^    \* \* \*\s*$/

    def parse_blocks(input)
      block_ended = false
      meta_ended = false

      blocks = []
      meta = {}
      out = {:meta => meta, :blocks => blocks}

      input.lines.each do |line|
        line.chomp!
        if BLANK_LINE =~ line
          block_ended = true
          meta_ended = true
        elsif COMMENT_LINE =~ line # skip
        elsif METADATA =~ line && !meta_ended
          meta[$1.downcase.to_sym] = meta_value($2)
        elsif block_ended || blocks.empty?
          # Start a new block-level element
          start_block(blocks, line)
          block_ended = false
        else
          blocks.last[:content] << line
        end
      end

      out
    end

    def start_block(blocks, line)
      case line
      when RULE_QUOTE
        blocks << build_block(:rule_quote)
      when RULE_BODY
        blocks << build_block(:rule)
      when HEADING
        blocks << build_block(:heading, $2).merge(level: $1.length)
      when FOOTNOTE_START
        blocks << build_block(:footnote, $2).merge(marker: $1)
      when FOOTNOTE_CONTINUE
        blocks << build_block(:footnote, $1)
      when RAGGED_LEFT
        blocks << build_block(:ragged_left, $1)
      when INDENTED_QUOTE
        blocks << build_block(:indented_quote, $1)
      when FLUSH_QUOTE
        blocks << build_block(:flush_quote, $1)
      when INDENTED
        blocks << build_block(:indented, $1)
      else # Flush
        blocks << build_block(:flush, line)
      end
    end

    def meta_value(value)
      v = value.strip
      case v
      when /^\d+$/ then v.to_i
      when /^\d\d\d\d-\d\d-\d\d$/ then Date.parse(v)
      when /^true|yes$/i then true
      when /^false|no$/i then false
      else v
      end
    end
  end
end
