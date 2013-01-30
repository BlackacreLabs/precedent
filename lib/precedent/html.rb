require_relative 'parse'
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
cite { font-style: normal; color: #777; }
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

  def self.simple_node(mapping, content, parent)
    name, css_class = mapping
    node = Nokogiri::XML::Node.new(name, parent)
    node['class'] = css_class if css_class
    add_nodes(content[:content], node)
    parent.add_child(node)
  end

  NODE_MAPPING = {
    :indented => 'p',
    :flush => ['p', 'flush'],
    :smallcaps => ['span', 'smallcaps'],
    :citation => 'cite',
    :emphasis => 'em',
    :quote => 'blockquote'
  }

  def self.add_nodes(content, parent)
    case content
    when Array
      content.each {|e| add_nodes(e, parent) }
    when Hash
      if (mapping = NODE_MAPPING[content[:type]])
        simple_node(mapping, content, parent)
      else
        case content[:type]
        when :heading
          simple_node("h#{content[:level]}", content, parent)
        when :rule
          parent.add_child(Nokogiri::XML::Node.new("hr", parent))
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
        when :break
          page = content[:page]
          a = Nokogiri::XML::Node.new('a', parent)
          a['class'] = 'break'
          a['data-page'] = page.to_s
          add_nodes(page.to_s, a)
          parent.add_child(a)
        when :footnote
          marker = content[:marker]
          aside = Nokogiri::XML::Node.new('aside', parent)
          aside['id'] = "footnote-#{marker}"
          children = content[:content]
          first = children.first
          backref = {
            :type => :back_reference, 
            :marker => marker
          }
          # Append a back reference to the first paragraph, then send it
          # down with the hash content to be appended to the <aside>.
          if first[:content].is_a?(Array)
            first[:content].unshift(backref)
          else
            first[:content] = [backref, first[:content]]
          end
          add_nodes(children, aside)
          parent.add_child(aside)
        # created under :footnote above
        when :back_reference
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
      end
    when String
      parent.add_child Nokogiri::XML::Text.new(content, parent)
    else
      raise "Unexpected element: #{content}"
    end
  end

  def self.add_footnotes(footnotes, parent)
    section = Nokogiri::XML::Node.new('section', parent)
    section['class'] = "footnotes"
    add_nodes(footnotes, section)
    parent.add_child(section)
  end
end
