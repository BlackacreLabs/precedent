require_relative 'parse'
require 'active_support/core_ext/hash/slice'

module Precedent
  public

  # Convert a list of block-level element hashes into a hash
  # representing the structure of the document as a whole.
  #
  # This format is more useful for certain output formatters, especially
  # those that need to generate footnotes inline (e.g. LaTeX) rather
  # than at the end of output (e.g. HTML).
  def self.load(source)
    blank = { :meta => {}, :content => [], :footnotes => {} }
    injected = inject_footnotes(parse(source).reduce(blank) do |mem, e|
      case e[:type]
      when :meta
        mem.merge({ :meta => mem[:meta].merge(e[:content]) })
      when :footnote
        note_hash = { e[:marker] => e[:content] }
        mem.merge({ :footnotes => mem[:footnotes].merge(note_hash) })
      else
        mem.merge({ :content => mem[:content] + [e] })
      end
    end)
    injected.merge(content: numbered(injected[:content], 1).first)
  end

  NUMBERED_TYPES = [:indented, :flush, :raggedleft]
  def self.numbered(node, start=1)
    if node.is_a?(Array)
      mapped = node.map {|n| ret, start = numbered(n, start) ; ret }
      [mapped, start]
    elsif node.is_a?(Hash) && node[:content]
      if NUMBERED_TYPES.include?(node[:type])
        [node.merge(number: start), start + 1]
      elsif node[:type] == :quote
        new_content, start = numbered(node[:content], start)
        [node.merge(content: new_content), start]
      else
        puts node
        [node, start]
      end
    else
      [node, start]
    end
  end

  # Replace reference hashes in ast[:content] with footnotes containing
  # the content in ast[:footnotes] for the corresponding marker
  def self.inject_footnotes(ast)
    footnotes = ast[:footnotes]
    if footnotes.nil?
      ast.slice(:meta, :content)
    else
      ast.slice(:meta).merge({
        :content => replace_references(ast[:content], footnotes)
      })
    end
  end

  # Recurse the tree of :content hashes, replacing :type == :reference
  # hashes with :type == :footnote hashes.
  def self.replace_references(content, footnotes)
    case content
    when String
      content
    when Array
      content.map {|c| replace_references(c, footnotes) }
    when Hash
      # Replacement happens here
      if content[:type] == :reference
        marker = content[:marker]
        footnote_content = footnotes[marker]
        if footnote_content.nil?
          raise MissingFootnoteError.new("Missing footnote #{marker}")
        end
        if footnote_content.count == 1
          footnote_content = footnote_content.first
        end
        { 
          :type => :footnote,
          :marker => marker,
          :content => footnote_content
        }
      else
        # hash with content
        if content[:content]
          content.merge({
            :content => replace_references(
              content[:content],
              footnotes
            )
          })
        # e.g. horizontal rules
        else
          content
        end
      end
    end
  end

  class MissingFootnoteError < Exception
  end
end
