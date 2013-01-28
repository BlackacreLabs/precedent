require 'treetop'
require_relative 'nodes'
require_relative 'node_patch'

module Precedent
  @@parser = Treetop.load(
    File.join(
      File.dirname(__FILE__), 'document.treetop'
    )
  ).new

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
