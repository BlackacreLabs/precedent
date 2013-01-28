require_relative 'parse'
require 'active_support/core_ext/hash/slice'

module Precedent
  # convert a list of block-level element hashes into a hash
  # representing the structure of the document as a whole
  def self.load(source)
    blank = { :meta => {}, :content => [], :footnotes => {} }
    inject_footnotes(parse(source).reduce(blank) do |mem, e|
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
  end

  private
  # replace reference hashes in ast[:content] with footnotes containing
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
      # REPLACEMENT
      if content[:type] == :reference
        marker = content[:marker]
        { 
          :type => :footnote,
          :marker => marker,
          :content => footnotes[marker]
        }
      else
        # hash with content
        if content[:content]
          content.merge({
            :content => replace_references(content[:content], footnotes)
          })
        # e.g. horizontal rules
        else
          content
        end
      end
    end
  end
end
