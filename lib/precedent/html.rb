require_relative 'load'
require 'nokogiri'

module Precedent
  def self.to_html(input, standalone=true)
    htmlify(Precedent.load(input), standalone)
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
  <body>
    <article></article>
  </body>
</html>
  eos

  def self.htmlify(ast, standalone, anchor_prefix='')
    content = ast[:content]
    fragment = Nokogiri::HTML::DocumentFragment.parse ""

    content.each do |element|
      fragment.add_child(
        render_element(fragment, element, false, anchor_prefix)
      )
    end

    footnotes = find_footnotes(content)
    unless footnotes.empty?
      section = Nokogiri::XML::Node.new('section', fragment)
      section['class'] = 'footnotes'
      footnotes.each do |e|
        section.add_child(
          render_element(section, e, true, anchor_prefix)
        )
      end
      fragment.add_child(section)
    end

    if standalone
      # parse as XML to avoid HTML formatting
      root = Nokogiri.XML(HTML5_SKELETON, &:noblanks)
      article = root.at_css('article')
      ast[:meta].each do |k, v|
        article["data-#{k}"] = v.to_s
      end
      article.add_child(fragment)
      "<!doctype html>\n#{root.root.to_xml(indent: 2)}"
    else
      fragment.to_xml(indent: 2)
    end
  end

  def self.render_element(fragment, element, in_footnotes, anchor_prefix)
    case element
    when Hash
      node = render_node(fragment, element, in_footnotes, anchor_prefix)
      content = element[:content]
      if content && element[:type] != :footnote
        if content.is_a?(Array)
          content.each do |child|
            node.add_child(
              render_element(
                fragment, child, in_footnotes, anchor_prefix
              )
            )
          end
        else
          node.add_child(
            render_element(
              fragment, content, in_footnotes, anchor_prefix
            )
          )
        end
      end
      return node
    when String
      Nokogiri::XML::Text.new(element, fragment)
    end
  end

  def self.simple_node(parent, (name, css_class))
    node = Nokogiri::XML::Node.new(name, parent)
    node['class'] = css_class if css_class
    node
  end

  SIMPLE_NODES = {
    :flush => ['p', 'numbered flush'],
    :indented => ['p', 'numbered'],
    :quote => 'blockquote',
    :citation => 'cite',
    :ragged_left => %w{p raggedleft},
    :emphasis => 'em',
    :smallcaps => %w{span smallcaps},
    :rule => 'hr'
  }

  def self.render_node(fragment, element, in_footnotes, anchor_prefix)
    content = element[:content]
    content = [content] unless content.is_a?(Array)
    if mapping = SIMPLE_NODES[element[:type]]
      simple_node(fragment, mapping)
    else
      case element[:type]
      when :heading
        node = Nokogiri::XML::Node.new("h#{element[:level]}", fragment)
      when :footnote
        node = Nokogiri::XML::Node.new('sup', fragment)
        a = Nokogiri::XML::Node.new('a', node)
        node['class'] = 'reference'
        marker = element[:marker]
        a['id'] = "#{anchor_prefix}reference-#{marker}"
        a['href'] = "##{anchor_prefix}footnote-#{marker}"
        a.add_child(
          Nokogiri::XML::Text.new(marker, fragment)
        )
        node.add_child(a)
      when :backref
        node = Nokogiri::XML::Node.new('sup', fragment)
        a = Nokogiri::XML::Node.new('a', node)
        node['class'] = 'reference'
        marker = element[:marker]
        a['href'] = "##{anchor_prefix}reference-#{marker}"
        a.inner_html = marker
        node.add_child(a)
      when :footnote_content
        node = Nokogiri::XML::Node.new('aside', fragment)
        marker = element[:marker]
        node['id'] = "#{anchor_prefix}footnote-#{marker}"
        backref = { :type => :backref, :marker => marker }
        unless content.first[:content].is_a?(Array)
          content.first[:content] = [content.first[:content]]
        end
        content.first[:content].unshift(backref)
      when :break
        node = Nokogiri::XML::Node.new('a', fragment)
        node['class'] = 'pageBreak'
        page = element[:page]
        node['data-page'] = page
        unless in_footnotes
          node['id'] = "#{anchor_prefix}page-#{page}"
        end
        node.add_child(
          Nokogiri::XML::Text.new(page.to_s, fragment)
        )
      else
        raise "Unknown element type: #{element[:type]}"
      end
      node
    end
  end

  def self.find_footnotes(ast)
    if ast.is_a?(Array)
      ast.map{|a| find_footnotes(a)}.flatten.compact
    elsif ast.is_a?(Hash)
      if ast[:type] == :footnote
        ast.merge(:type => :footnote_content)
      elsif ast[:content]
        find_footnotes(ast[:content])
      end
    end
  end

end
