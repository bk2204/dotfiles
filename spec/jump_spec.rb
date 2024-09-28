require_relative 'spec_helper'

describe :dct_jump do
  before(:all) do
    @dir = TestDir.new
    File.write(File.join(@dir.test_bin, 'ex'), %Q[#!/bin/sh\nprintf '"%s" ' ex "$@"\n])
    @env = {"DISPLAY" => "", "TERM" => "dumb", "XDG_CURRENT_DESKTOP" => "X-Generic", "BROWSER" => "/bin/echo"}
    @renv = @env.merge("PATH" => @dir.test_bin)
  end

  it 'should greet appropriately' do
    @dir = TestDir.new
    expect(@dir.cmd(['bin/dct-jump', 'hello'])).to eq "Hello, world!\n"
    expect(@dir.cmd(['bin/dct-jump', 'hello', 'Toronto'])).to eq "Hello, Toronto!\n"
    expect(@dir.cmd(['bin/dct-jump', 'hello', 'New', 'Jersey'])).to eq "Hello, New Jersey!\n"
  end

  it 'should open expected URLs' do
    @dir = TestDir.new
    expect(@dir.cmd(%w[bin/dct-jump es sin querer queriendo], **@env)).to eq "https://www.wordreference.com/esen/sin%20querer%20queriendo\n"
    expect(@dir.cmd(%w[bin/dct-jump esfr sin querer queriendo], **@env)).to eq "https://www.wordreference.com/fres/sin%20querer%20queriendo\n"
    expect(@dir.cmd(%w[bin/dct-jump fr bon débarras], **@env)).to eq "https://www.wordreference.com/fren/bon%20d%c3%a9barras\n"
  end

  it 'should edit notes' do
    expect(@dir.cmd_with_exes(['ex'], %w[bin/dct-jump notes homedir], **@renv)).to eq %Q["ex" "+Notes homedir" ]
  end
end
