module Treetop
  module Runtime
    class SyntaxNode
      # Convenience pass-through method for building ASTs. Intersitial
      # Treetop nodes can just label subrules their "content" and pass
      # through during AST construction.
      def build
        elements.map(&:build) if elements
      end
    end
  end
end
