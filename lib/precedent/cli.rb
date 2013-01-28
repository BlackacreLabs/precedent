require 'thor'

module Precedent
  class CLI < Thor
    option :file,
      :aliases => '-f',
      :type => :string,
      :desc => 'file to translate'
    desc "html", "translate Precedent markup into HTML5"
    def html()
      if options[:file]
        input = open(options[:file], 'r').read
      else
        input = STDIN.read
      end
      require_relative 'html'
      STDOUT.write Precedent.to_html(input)
    end
  end
end
