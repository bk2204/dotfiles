require_relative 'spec_helper'

describe :zsh do
  before(:all) do
    @dir = TestDir.new
  end

  context 'editor' do
    it 'should set EDITOR to nvim-gtk with DISPLAY' do
      expect(@dir.cmd(['zsh', '-c', 'echo $EDITOR'], 'DISPLAY' => 'something')).to eq "nvim-gtk --no-fork\n"
    end

    it 'should set VISUAL to gvim with DISPLAY' do
      expect(@dir.cmd(['zsh', '-c', 'echo $VISUAL'], 'DISPLAY' => 'something')).to eq "nvim-gtk --no-fork\n"
    end

    it 'should set EDITOR to ex with non-empty TERM' do
      expect(@dir.cmd(['zsh', '-c', 'echo $EDITOR'], 'TERM' => 'xterm-256color')).to eq "ex\n"
    end

    it 'should set VISUAL to nvim with non-empty TERM' do
      expect(@dir.cmd(['zsh', '-c', 'echo $VISUAL'], 'TERM' => 'xterm-256color')).to eq "nvim\n"
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
                      'TERM' => 'screen-256color')).to eq "nvim\n"
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

  context 'prompt' do
    it 'should not print escape characters with a dumb terminal' do
      expect(@dir.cmd(['zsh', '-c', 'source .zshrc; echo $PS1'])).not_to match(/\x1b/)
      expect(@dir.cmd(['zsh', '-c', 'source .zshrc; echo $PS1'], 'TERM' => 'dumb')).not_to match(/\x1b/)
    end
  end
end
