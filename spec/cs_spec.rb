require_relative 'spec_helper'
require_relative 'scripts/dct_cs'

describe :dct_cs do
  it 'should compute port correctly' do
    cases = {
      # All of these are expired and destroyed.
      "bk2204-opulent-waffle-jg6xp47x6cqx7" => 52896,
    }
    cases.each do |id, port|
      expect(Processor.new(StringIO.new, StringIO.new).port(id)).to eq(port)
    end
  end

  it 'should escape strings correctly' do
    p = Processor.new(StringIO.new, StringIO.new)
    expect(p.sq_quote_inner("abcdefg")).to eq "abcdefg"
    expect(p.sq_quote_one("abcdefg")).to eq "'abcdefg'"
    expect(p.sq_quote_inner("a b c'd\ne\\fg")).to eq %Q[a b c'\\''d\ne\\fg]
    expect(p.sq_quote_one("a b c'd\ne\\fg")).to eq %Q['a b c'\\''d\ne\\fg']
  end
end
