require_relative 'spec_helper'

describe :dct_erb do
  before(:all) do
    @dir = TestDir.new
  end

  context 'generate' do
    EXAMPLE_YAML = <<~EOF
    ---
    arg1: abc
    arg2: 123
    EOF

    EXAMPLE_ERB = <<~EOF
    This is the first argument:
    <%= @data["arg1"] -%>
    More
    This is the second argument:
    <%= @data["arg2"] %>
    More
    EOF

    EXAMPLE_RESULT = <<~EOF
    This is the first argument:
    abcMore
    This is the second argument:
    123
    More
    EOF

    it 'should generate expected output' do
      File.write(File.join(@dir.tempdir, "foo.yaml"), EXAMPLE_YAML)
      File.write(File.join(@dir.tempdir, "foo.erb"), EXAMPLE_ERB)
      expect(@dir.stream(['bin/dct-erb', '-f', 'foo.yaml', 'foo.erb'], '')).to eq EXAMPLE_RESULT
    end

    it 'should write to a file with -o' do
      File.write(File.join(@dir.tempdir, "foo.yaml"), EXAMPLE_YAML)
      File.write(File.join(@dir.tempdir, "foo.erb"), EXAMPLE_ERB)
      @dir.cmd(['bin/dct-erb', '-f', 'foo.yaml', '-o', 'foo.out', 'foo.erb'])
      expect(File.read(File.join(@dir.tempdir, 'foo.out'))).to eq EXAMPLE_RESULT
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
