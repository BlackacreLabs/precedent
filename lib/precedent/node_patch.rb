module Treetop
  module Runtime
    class SyntaxNode
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
