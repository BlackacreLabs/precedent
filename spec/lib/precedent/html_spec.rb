require_relative '../../../lib/precedent/html'
require 'faker'
include Precedent

describe Precedent do
  let(:first) { Faker::Lorem.sentence }
  let(:second) { Faker::Lorem.sentence }
  let(:third) { Faker::Lorem.sentence }
  let(:word) { Faker::Lorem.word }
  let(:another_word) { Faker::Lorem.word }

  it 'outputs a basic document skeleton' do
    result = Precedent.to_html(<<-eos
#{word.capitalize}: #{another_word}

# #{word}

  #{first}
    eos
    )
    result.should include "<h1>#{word}</h1>"
    result.should match(
      %r{<article.+data-#{word.downcase}="#{another_word}"}
    )
    result.should include("<p>#{first}</p>")
  end

  specify do
    Precedent.to_html(<<-eos
# #{word}

* * *
    eos
    ).should include "<hr/>"
  end

  specify do
    result = Precedent.to_html(<<-eos
      #{first}

    #{second}
    eos
    )
    result.should include("<blockquote>")
    result.should include("<p>#{first}</p>")
    result.should include("<p class=\"flush\">#{second}</p>")
  end

  specify do
    marker = (1 + rand(1000)).to_s
    result = Precedent.to_html(<<-eos
#{first}[[#{marker}]] #{second}

^#{marker} #{third}
    eos
    )
    result.should match(
      /<sup class="reference"><a.+id=\"reference-#{marker}/
    )
    result.should match(/<section.+class=\"footnotes\">/)
    result.should match(/<aside.+id=\"footnote-#{marker}/)
  end

  specify do
    result = Precedent.to_html("#{first}")
    result.should_not match(/<section class=\"footnotes\"/)
  end

  context 'inline elements' do
    specify do
      Precedent.to_html(
        "\\\\#{word}\\\\"
      ).should include("<em>#{word}</em>")
    end

    specify do
      Precedent.to_html(
        "<<#{word}>>"
      ).should include("<span class=\"smallcaps\">#{word}</span>")
    end

    specify do
      Precedent.to_html(
        "{{//#{word}// <<#{another_word}>>}}"
      ).should include("<cite>")
    end

    specify do
      page = (1 + rand(1000)).to_s
      result = Precedent.to_html("@@#{page}@@")
      result.should match(%r{<a.+class="pageBreak"})
      result.should include("data-page=\"#{page}\"")
      result.should match(%r{>#{page}</a>})
    end
  end

  specify {
    result = Precedent.to_html("#{first}", false)
    result.should_not match(%r{<!doctype})
  }
end
