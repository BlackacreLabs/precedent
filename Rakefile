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
  File.open(t.name, 'wb') do |f|
    f.puts("# encoding: utf-8", contents)
  end
end

task :clean do
  require 'fileutils'
  $generated.each do |f|
    FileUtils.rm_f(f)
  end
end

task :default => [:grammars, :spec]
