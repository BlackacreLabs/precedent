module Treetop
  module Runtime
    class SyntaxNode
      # Convenience method for building ASTs.
      #
      # Treetop grammars can just label nodes "content", and not bother
      # implementing the build method inline.
      def build
        if respond_to?(:content)
          content.build
        elsif elements
          elements.map(&:build)
        end
      end
    end
  end
end
