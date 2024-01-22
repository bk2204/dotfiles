require 'tempfile'
require 'tmpdir'

class TestDir
  def initialize
    @dir = Dir.mktmpdir
    @test_bin = File.join(@dir, "test-bin")
    Dir.mkdir(@test_bin)
    system({ "HOME" => @dir, "PATH" => ENV["PATH"] }, "make", "install", :out => "/dev/null")
  end

  def tempdir
    @dir
  end

  def setup_restricted_path(exes)
    exes.each do |name|
      path = File.join(@test_bin, name)
      File.open(path, "w")
      File.chmod(0700, path)
    end
    real_path = ENV["PATH"].split(":")
    %w[sed grep id hostname].each do |name|
      real_path.each do |dir|
         loc = File.join(dir, name)
         if File.exist? loc
           File.symlink(loc, File.join(@test_bin, name))
           break
         end
      end
    end
  end

  def cmd(command, **env)
    env["HOME"] = @dir
    env["PATH"] = ENV["PATH"]
    IO.popen(env, command, :unsetenv_others => true, :in => "/dev/null", :chdir => @dir).read
  end

  def cmd_with_exes(exes, command, **env)
    env["HOME"] = @dir
    env["PATH"] = @test_bin
    env["BMC_TEST"] = "1"
    setup_restricted_path(exes)
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
