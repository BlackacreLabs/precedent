require 'thor'

require_relative '../precedent'

module Precedent
  class CLI < Thor
    OUTPUT_FORMATS = {
      :json => lambda { |hashes, pretty|
        require 'json'
        message = pretty ? :pretty_generate : :generate
        JSON.send(message, hashes)
      },
      :yaml => lambda { |hashes, pretty|
        require 'yaml'
        hashes.to_yaml
      }
    }

    option :pretty,
      :aliases => '-p',
      :type => :boolean,
      :default => false,
      :desc => "Pretty output"

    option :format,
      :aliases => '-f',
      :default => OUTPUT_FORMATS.keys.first,
      :desc => "Output format: " + OUTPUT_FORMATS.keys.join('|')

    desc "hashes [FILE]", "Translate Precedent markup"

    def hashes(file=STDIN)
      input = file.is_a?(String) ? File.read(file) : file.read
      parsed = Precedent.new(input).to_hashes
      output = OUTPUT_FORMATS[options[:format].to_sym].call(parsed, options[:pretty])
      STDOUT.write(output)
    end

    option :pretty,
      :aliases => '-p',
      :type => :boolean,
      :default => false,
      :desc => "Pretty output"

    option :format,
      :aliases => '-f',
      :default => OUTPUT_FORMATS.keys.first,
      :desc => "Output format: " + OUTPUT_FORMATS.keys.join('|')

    desc "record [FILE]", "Translate Precedent markup"

    def record(file=STDIN)
      input = file.is_a?(String) ? File.read(file) : file.read
      parsed = Precedent.new(input).to_indexable_record
      output = OUTPUT_FORMATS[options[:format].to_sym].call(parsed, options[:pretty])
      STDOUT.write(output)
    end
  end
end

if __FILE__ == $0
  Precedent::CLI.start(ARGV)
end
