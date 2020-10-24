require_relative 'spec_helper'

describe :format_text do
  before(:all) do
    @dir = TestDir.new
  end

  context 'editor' do
    it 'should wrap lines' do
      input = <<~EOF
      This is some input.
      This is some more input.
      More text.

      Text.
      More text.
      EOF
      output = <<~EOF
      This is some input. This is some more input. More text.

      Text. More text.
      EOF
      expect(@dir.stream(['bin/format-text'], input)).to eq output
    end

    it 'should not wrap lines beginning with indentation' do
      input = <<~EOF
      This is some input.
      This is some more input.
      More text.

        This is some indented text.
        More indented text.

      Text.
      More text.
      EOF
      output = <<~EOF
      This is some input. This is some more input. More text.

        This is some indented text.
        More indented text.

      Text. More text.
      EOF
      expect(@dir.stream(['bin/format-text'], input)).to eq output
    end

    it 'should wrap indented lines in a bulleted list' do
      input = <<~EOF
      This is some input.
      This is some more input.
      More text.

      - This is a list.
        More stuff in the list.
      - This is also a list.
        More stuff.

      Text.
      More text.
      EOF
      output = <<~EOF
      This is some input. This is some more input. More text.

      - This is a list. More stuff in the list.
      - This is also a list. More stuff.

      Text. More text.
      EOF
      expect(@dir.stream(['bin/format-text'], input)).to eq output
      expect(@dir.stream(['bin/format-text'], input.gsub('-', '*'))).to eq output.gsub('-', '*')
      expect(@dir.stream(['bin/format-text'], input.gsub('-', '•'))).to eq output.gsub('-', '•')
    end

    it 'should wrap indented lines in a numbered list' do
      input = <<~EOF
      This is some input.
      This is some more input.
      More text.

      1. This is a list.
         More stuff in the list.
      2. This is also a list.
         More stuff.

      Text.
      More text.
      EOF
      output = <<~EOF
      This is some input. This is some more input. More text.

      1. This is a list. More stuff in the list.
      2. This is also a list. More stuff.

      Text. More text.
      EOF
      expect(@dir.stream(['bin/format-text'], input)).to eq output

      input = <<~EOF
      This is some input.
      This is some more input.
      More text.

      . This is a list.
        More stuff in the list.
      . This is also a list.
        More stuff.

      Text.
      More text.
      EOF
      output = <<~EOF
      This is some input. This is some more input. More text.

      . This is a list. More stuff in the list.
      . This is also a list. More stuff.

      Text. More text.
      EOF
      expect(@dir.stream(['bin/format-text'], input)).to eq output
    end
  end
end
