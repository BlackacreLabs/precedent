require_relative '../../../lib/precedent/parse'
require 'faker'
require 'ap'
include Precedent

describe Precedent do
  context 'block elements' do
    specify {
      first = Faker::Lorem.sentence
      second = Faker::Lorem.sentence
      input = <<-eos
  #{first}

#{second}
      eos
      result = Precedent.parse(input)
      result.should == [
        { :type => :indented, :content => first },
        { :type => :flush, :content => second }
      ]
    }
  end
end
