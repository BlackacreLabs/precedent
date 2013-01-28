require "bundler/gem_tasks"

$generated = Dir['**/*.treetop'].map {|t| t.sub('.treetop', '.rb') }

desc "Generate Treetop grammars"
task :grammars => $generated

compiler = nil
rule '.rb' => '.treetop' do |t|
  require 'treetop' unless defined? Treetop
  compiler ||= Treetop::Compiler::GrammarCompiler.new
  compiler.compile(t.source, t.name)
  contents = File.read(t.name)
  # Append an encoding comment to avoid errors when using non-ASCII
  # characters in Treetop character classes
  File.open(t.name, 'wb') do |f|
    f.puts("# encoding: utf-8", contents)
  end
end

desc "Detect long source code lines"
task :lines do
  exclusions = $generated.map {|g| "grep -F -v '#{g}'" }
  sh(<<-eos
if git grep -nE '.{73,}' | #{exclusions.join ' | '}
then exit 1
else exit 0
fi
  eos
  )
end

desc "Delete generated Treetop grammars"
task :clean do
  require 'fileutils'
  $generated.each do |f|
    FileUtils.rm_f(f)
  end
end

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => [:lines, :grammars, :spec]
