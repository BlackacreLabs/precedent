require 'thor'

module Precedent
  # Command Line Interface
  class CLI < Thor
    option :file,
      :aliases => '-f',
      :type => :string,
      :desc => 'File to translate'
    desc "html", "Translate Precedent markup into HTML5"
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
