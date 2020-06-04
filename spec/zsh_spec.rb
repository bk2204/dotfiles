require_relative 'spec_helper'

describe :zsh do
  before(:all) do
    @dir = TestDir.new
  end

  context 'editor' do
    it 'should set EDITOR to gvim with DISPLAY' do
      expect(@dir.cmd(['zsh', '-c', 'echo $EDITOR'], 'DISPLAY' => 'something')).to eq "gvim -f\n"
    end

    it 'should set VISUAL to gvim with DISPLAY' do
      expect(@dir.cmd(['zsh', '-c', 'echo $VISUAL'], 'DISPLAY' => 'something')).to eq "gvim -f\n"
    end

    it 'should set EDITOR to ex with non-empty TERM' do
      expect(@dir.cmd(['zsh', '-c', 'echo $EDITOR'], 'TERM' => 'xterm-256color')).to eq "ex\n"
    end

    it 'should set VISUAL to vim with non-empty TERM' do
      expect(@dir.cmd(['zsh', '-c', 'echo $VISUAL'], 'TERM' => 'xterm-256color')).to eq "vim\n"
    end

    it 'should set EDITOR to ex with SSH session and terminal multiplexor' do
      expect(@dir.cmd(['zsh', '-c', 'source .zshrc; echo $EDITOR'],
                      'DISPLAY' => 'something',
                      'SSH_TTY' => 'tty',
                      'TERM' => 'screen-256color')).to eq "ex\n"
    end

    it 'should set VISUAL to vim with SSH session and terminal multiplexor' do
      expect(@dir.cmd(['zsh', '-c', 'source .zshrc; echo $VISUAL'],
                      'DISPLAY' => 'something',
                      'SSH_TTY' => 'tty',
                      'TERM' => 'screen-256color')).to eq "vim\n"
    end

    it 'should set EDITOR to ex with TERM=dumb' do
      expect(@dir.cmd(['zsh', '-c', 'echo $EDITOR'], 'TERM' => 'dumb')).to eq "ex\n"
    end

    it 'should set VISUAL to ex with TERM=dumb' do
      expect(@dir.cmd(['zsh', '-c', 'echo $VISUAL'], 'TERM' => 'dumb')).to eq "ex\n"
    end

    it 'should set EDITOR to ex with no TERM' do
      expect(@dir.cmd(['zsh', '-c', 'echo $EDITOR'])).to eq "ex\n"
    end

    it 'should set VISUAL to ex with no TERM' do
      expect(@dir.cmd(['zsh', '-c', 'echo $VISUAL'])).to eq "ex\n"
    end
  end
end
