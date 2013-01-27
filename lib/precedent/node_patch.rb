module Treetop
  module Runtime
    class SyntaxNode
      def build
        if respond_to?(:content)
          content.build
        else
          if elements.count == 1
            elements.first.build
          else
            elements.map(&:build)
          end
        end
      end
    end
  end
end
