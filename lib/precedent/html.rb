require_relative 'parse'
require 'ap'
require 'nokogiri'

module Precedent
  public
  def self.to_html(input)
    htmlify(parse(input))
  end

  HTML5_SKELETON = <<-eos
<html lang="en">
  <head>
    <meta charset="UTF-8"/>
    <title>Precedent Document</title>
    <style>
.smallcaps { font-variant: small-caps; }
p { text-indent: 3ex; }
.flush { text-indent: 0ex; }
    </stle>
  </head>
  <body></body>
</html>
  eos

  private
  def self.htmlify(doc)
    footnotes, rest = doc.partition { |e| e[:type] == :footnote }
    metas, content = rest.partition { |e| e[:type] == :meta }

    # parse as XML to avoid HTML formatting
    xml = Nokogiri.XML(HTML5_SKELETON, &:noblanks)
    body = xml.at_css('body')
    article = Nokogiri::XML::Node.new("article", xml)
    body.add_child(article)

    add_meta(metas, article)
    add_nodes(content, article)
    add_footnotes(footnotes, article) unless footnotes.empty?
    # format the root to avoid <?xml> in output
    "<!doctype html>\n#{xml.root.to_xml(indent: 2)}"
  end

  def self.add_meta(metas, parent)
    metas.map {|m| m[:content] }.each do |hash|
      hash.each do |key, value|
        parent["data-#{key.downcase}"] = value
      end
    end
  end

  def self.add_nodes(content, parent)
    case content
    when Array
      content.each {|e| add_nodes(e, parent) }
    when Hash
      case content[:type]
      when :indented
        p = Nokogiri::XML::Node.new('p', parent)
        add_nodes(content[:content], p)
        parent.add_child(p)
      when :flush
        p = Nokogiri::XML::Node.new('p', parent)
        p['class'] = 'flush'
        add_nodes(content[:content], p)
        parent.add_child(p)
      when :heading
        level = content[:level]
        h = Nokogiri::XML::Node.new("h#{level}", parent)
        add_nodes(content[:content], h)
        parent.add_child(h)
      when :rule
        parent.add_child(Nokogiri::XML::Node.new("hr", parent))
      when :quote
        blockquote = Nokogiri::XML::Node.new("blockquote", parent)
        add_nodes(content[:content], blockquote)
        parent.add_child(blockquote)
      when :reference
        marker = content[:marker]
        sup = Nokogiri::XML::Node.new("sup", parent)
        a = Nokogiri::XML::Node.new("a", sup)
        a['id'] = "reference-#{marker}" 
        a['class'] = "reference"
        a['href'] = "#footnote-#{marker}"
        a.inner_html = marker
        sup.add_child(a)
        parent.add_child(sup)
      when :footnote
        marker = content[:marker]
        aside = Nokogiri::XML::Node.new('aside', parent)
        aside['id'] = "footnote-#{marker}"
        children = content[:content]
        first = children.first
        backref = {
          :type => :backref, 
          :marker => marker
        }
        # append a back reference to the first paragraph
        if first[:content].is_a?(Array)
          first[:content].unshift(backref)
        else
          first[:content] = [backref, first[:content]]
        end
        add_nodes(children, aside)
        parent.add_child(aside)
      when :backref
        marker = content[:marker]
        sup = Nokogiri::XML::Node.new("sup", parent)
        a = Nokogiri::XML::Node.new("a", sup)
        a['class'] = "back-reference"
        a['href'] = "#reference-#{marker}"
        a.inner_html = marker
        sup.add_child(a)
        parent.add_child(sup)
        # insert space between back reference and paragraph text
        parent.add_child(Nokogiri::XML::Text.new(' ', parent))
      end
    when String
      parent.add_child Nokogiri::XML::Text.new(content, parent)
    end
  end

  def self.add_footnotes(footnotes, parent)
    section = Nokogiri::XML::Node.new('section', parent)
    section['class'] = "footnotes"
    add_nodes(footnotes, section)
    parent.add_child(section)
  end
end
