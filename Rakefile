require "bundler/gem_tasks"

# Treetop grammars

GRAMMARS = FileList.new('**/*.treetop').sub('.treetop', '.rb')

desc "Generate Treetop grammars"
task :grammars => GRAMMARS

require 'rake/clean'
CLEAN.include(GRAMMARS)

compiler = nil
rule '.rb' => '.treetop' do |t|
  unless defined? Treetop
    require 'treetop' 
    require './lib/precedent/treetop_patch.rb'
  end
  compiler ||= Treetop::Compiler::GrammarCompiler.new
  compiler.compile(t.source, t.name)
end

# Performance

desc 'Profile a program run'
task :profile do
  require 'ruby-prof'
  require_relative 'lib/precedent/load.rb'
  result = RubyProf.profile do
    Precedent.load(File.read('spec/fixtures/long_opinion.pre'))
  end
  printer = RubyProf::GraphPrinter.new(result)
  printer.print(STDOUT, {})
end

# Specifications

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec => [:grammars])

task :default => :rspec
