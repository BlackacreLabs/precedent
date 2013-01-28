require 'treetop'
require_relative 'nodes'
require_relative 'node_patch'

module Precedent
  # Keep a single module-level instance of the generated parser.
  @@parser = Treetop.load(
    File.join(
      File.dirname(__FILE__), 'document.treetop'
    )
  ).new

  # Programmatic interface to the Treetop-generated parsers.
  #
  # This format is more useful for certain output formatters, especially
  # those that need to generate footnotes as the end of output (e.g.
  # HTML) rather than inline (e.g. LaTeX).
  def self.parse(input)
    tree = @@parser.parse(input)
    if tree.nil?
      raise Exception,
        "Parse error at offset: #{@@parser.index} " +
        "#{@@parser.failure_reason}"
    end
    tree.build
  end
end
