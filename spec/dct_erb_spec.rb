require_relative 'spec_helper'

describe :dct_erb do
  before(:all) do
    @dir = TestDir.new
  end

  context 'generate' do
    it 'should generate expected output' do
      yaml = <<~EOF
      ---
      arg1: abc
      arg2: 123
      EOF
      erb = <<~EOF
      This is the first argument:
      <%= @data["arg1"] -%>
      More
      This is the second argument:
      <%= @data["arg2"] %>
      More
      EOF
      File.write(File.join(@dir.tempdir, "foo.yaml"), yaml)
      File.write(File.join(@dir.tempdir, "foo.erb"), erb)
      expected = <<~EOF
      This is the first argument:
      abcMore
      This is the second argument:
      123
      More
      EOF
      expect(@dir.stream(['bin/dct-erb', '-f', 'foo.yaml', 'foo.erb'], '')).to eq expected
    end

    it 'should gracefully handle /dev/null as a YAML file' do
      erb = <<~EOF
      The platform is this: <%= RUBY_PLATFORM -%>
      EOF
      File.write(File.join(@dir.tempdir, "bar.erb"), erb)
      expect(@dir.stream(['bin/dct-erb', '-f', '/dev/null', 'bar.erb'], '')).to eq "The platform is this: #{RUBY_PLATFORM}"
    end
  end
end
