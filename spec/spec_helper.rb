require 'securerandom'
require 'tempfile'
require 'tmpdir'

class TestConfig
  def self.ci?
    !!ENV["CI"]
  end

  def self.docker_tests?
    !!ENV["DOCKER_IMAGE"]
  end

  def self.docker_image
    ENV["DOCKER_IMAGE"]
  end
end

class TestDockerImage
  def initialize(image)
    @image = image
    @root = repo_root
  end

  def run
    name = "dotfiles-spec-#{SecureRandom.alphanumeric(20)}"
    pid = Process.spawn("docker", "run", "--name", name, "-v", "#{@root}:/usr/src/repo", @image, "sh", "-c", "while true; do sleep 20; done")
    ObjectSpace.define_finalizer(self, Remover.new(name, pid))
    @name = name
    sleep 2
  end

  def setup
    exec("mkdir -p /usr/src/dotfiles && tar -C /usr/src/dotfiles --exclude=.git -cf - . | tar -C /usr/src/dotfiles -xf -", workdir: nil)
  end

  def exec(command, workdir: "/usr/src/repo")
    args = ["-w", workdir] if workdir
    system("docker", "exec", *args, @name, "sh", "-c", command)
  end

  private

  class Remover
    def initialize(name, pid)
      @name = name
      @pid = pid
    end

    def call(*args)
      system("docker", "kill", @name)
    end
  end

  def repo_root
    path = File.join(File.dirname(__FILE__), "..")
    raise "Can't find repository root (tried #{path})" unless File.exists? File.join(path, "Makefile")
    path
  end
end

class TestDir
  attr_reader :test_bin

  def initialize(config_yaml: nil)
    @dir = Dir.mktmpdir
    @test_bin = File.join(@dir, "test-bin")
    Dir.mkdir(@test_bin)
    @src = File.join(@dir, "src")
    Dir.mkdir(@src)
    extra_env = {}
    if config_yaml
      @config_path = File.join(@dir, "config.yaml")
      fp = File.open(@config_path, "wb")
      fp.write(config_yaml)
      fp.close
      extra_env = { "CONFIG_FILE" => @config_path }
    end
    FileUtils.cp_r(".", @src)
    system({ "HOME" => @dir, "PATH" => ENV["PATH"], **extra_env }, "make", "clean", out: "/dev/null", chdir: @src)
    system({ "HOME" => @dir, "PATH" => ENV["PATH"], **extra_env }, "make", "install", out: "/dev/null", chdir: @src)
  end

  def tempdir
    @dir
  end

  def setup_restricted_path(exes)
    exes.each do |name|
      path = File.join(@test_bin, name)
      fp = File.open(path, File::WRONLY | File::CREAT)
      File.chmod(0700, path)
      fp.close
    end
    real_path = ENV["PATH"].split(":")
    %w[sed grep id hostname ruby zsh sh printf].each do |name|
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

  def stream(command, input, **options)
    dir = options[:chdir] || @dir
    env = options[:env] || {}
    env["HOME"] = @dir
    env["PATH"] = ENV["PATH"]
    file = Tempfile.new()
    begin
      file.write(input)
      file.flush
      IO.popen(env, command, :unsetenv_others => true, :in => file.path, :err => "/dev/stderr", :chdir => dir).read
    ensure
      file.close
      file.unlink
    end
  end
end
