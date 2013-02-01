require 'thor'

module Precedent
  # Command Line Interface
  class CLI < Thor
    desc "html [FILE]", "Translate Precedent markup into HTML5"
    method_option :fragment,
      :aliases => '-f',
      :desc => 'Output a fragment, not a complete document',
      :type => :boolean,
      :default => false
    def html(file=STDIN)
      input = file.is_a?(String) ? File.read(file) : file.read
      require_relative 'html'
      STDOUT.write(Precedent.to_html(input, !options[:fragment]))
    end

    option :indent,
      :aliases => '-i',
      :type => :boolean,
      :default => false,
      :desc => "Output indented JSON"
    desc "json [FILE]", "Translate Precedent markup into JSON"
    def json(file=STDIN)
      input = file.is_a?(String) ? File.read(file) : file.read
      require_relative 'load'
      require 'json'
      STDOUT.write(
        if options[:indent]
          JSON::pretty_generate(Precedent.load(input))
        else
          JSON::generate(Precedent.load(input))
        end
      )
    end

    desc "yaml [FILE]", "Translate Precedent markup into YAML"
    def yaml(file=STDIN)
      input = file.is_a?(String) ? File.read(file) : file.read
      require_relative 'load'
      require 'yaml'
      STDOUT.write(Precedent.load(input).to_yaml)
    end

    desc "xml [FILE]", "Translate Precedent markup into XML"
    def xml(file=STDIN)
      input = file.is_a?(String) ? File.read(file) : file.read
      require_relative 'load'
      require 'xmlsimple'
      STDOUT.write(
        XmlSimple.xml_out(
          Precedent.load(input),
          # TODO: Better XmlSimple configuration
          :RootName => 'document'
        )
      )
    end

    desc "syntax [FILE]", "Check markup syntax"
    def syntax(file=STDIN)
      input = file.is_a?(String) ? File.read(file) : file.read
      require_relative 'load'
      begin
        Precedent.load(input)
        puts "Syntax OK"
      rescue Exception => e
        STDERR.write options[:file] + ': ' if options[:file]
        STDERR.puts e.to_s
        exit 1
      end
    end
  end
end
