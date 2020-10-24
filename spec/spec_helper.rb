require 'tempfile'
require 'tmpdir'

class TestDir
  def initialize
  @dir = Dir.mktmpdir
  system({ "HOME" => @dir, "PATH" => ENV["PATH"] }, "make", "install", :out => "/dev/null")
  end

  def cmd(command, **env)
    env["HOME"] = @dir
    env["PATH"] = ENV["PATH"]
    IO.popen(env, command, :unsetenv_others => true, :in => "/dev/null", :chdir => @dir).read
  end

  def stream(command, input, **env)
    env["HOME"] = @dir
    env["PATH"] = ENV["PATH"]
    file = Tempfile.new()
    begin
      file.write(input)
      file.flush
      IO.popen(env, command, :unsetenv_others => true, :in => file.path, :err => "/dev/stderr", :chdir => @dir).read
    ensure
      file.close
      file.unlink
    end
  end
end
