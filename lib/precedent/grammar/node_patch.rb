module Treetop
  module Runtime
    class SyntaxNode
      # Convenience pass-through method for building ASTs. Intersitial
      # Treetop nodes can just label subrules their "content" and pass
      # through during AST construction.
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
