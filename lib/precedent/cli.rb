require 'thor'

require_relative '../precedent'

module Precedent
  class CLI < Thor
    default_task :translate

    option :pretty,
      :aliases => '-p',
      :type => :boolean,
      :default => false,
      :desc => "Pretty output"

    OUTPUT_FORMATS = {
      :json => lambda { |hashes, pretty|
        require 'json'
        message = pretty ? :pretty_generate : :generate
        JSON.send(message, hashes)
      },
      :yaml => lambda { |hashes, pretty|
        require 'yaml'
        STDOUT.write(hashes)
      }
    }

    option :format,
      :aliases => '-f',
      :default => OUTPUT_FORMATS.keys.first,
      :desc => "Output format: " + OUTPUT_FORMATS.keys.join('|')

    desc "translate [FILE]", "Translate Precedent markup"

    def translate(file=STDIN)
      input = file.is_a?(String) ? File.read(file) : file.read
      parsed = Precedent.new(input).to_hashes
      output = OUTPUT_FORMATS[options[:format].to_sym].call(parsed, options[:pretty])
      STDOUT.write(output)
    end
  end
end
