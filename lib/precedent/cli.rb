require 'thor'

module Precedent
  # Command Line Interface
  class CLI < Thor
    class_option :file,
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

    desc "json", "Translate Precedent markup into JSON"
    def json()
      if options[:file]
        input = open(options[:file], 'r').read
      else
        input = STDIN.read
      end
      require 'json'
      require_relative 'load'
      STDOUT.write(JSON::pretty_generate(Precedent.load(input)))
    end

    desc "syntax", "Check markup syntax"
    def syntax()
      if options[:file]
        input = open(options[:file], 'r').read
      else
        input = STDIN.read
      end
      require_relative 'load'
      begin
        Precedent.load(input)
        puts "Syntax OK"
      rescue Exception => e
        if options[:file]
          STDERR.write options[:file] + ': '
        end
        STDERR.puts e.to_s
        exit 1
      end
    end
  end
end
