require_relative 'spec_helper'
load File.join(File.dirname(__FILE__), '..', 'snippets', 'exec', 'randomgen')

describe :randomgen do
  def run(args, stdin: '')
    stdout = StringIO.new("", "wb")
    RandomGen.main(args, StringIO.new(stdin), stdout)
    stdout.string
  end

  context 'fixed seed' do
    SEED = "\x01Hello, world!"
    ESCAPED_SEED = "\\x01Hello, world!"

    it 'should generate distinct numbers with just a high range' do
      res1 = run(['--seed', SEED] + %w[--distinct 10:256])
      res2 = run(['--escaped', '--seed', ESCAPED_SEED] + %w[--distinct 10:256])
      expect(res1).to eq res2
      expect(res1).to eq "9 34 240 116 223 241 197 129 100 82\n"
    end

    it 'should generate distinct numbers with high and low ranges' do
      res1 = run(['--seed', SEED] + %w[--distinct 10:1:256])
      res2 = run(['--escaped', '--seed', ESCAPED_SEED] + %w[--distinct 10:1:256])
      expect(res1).to eq res2
      expect(res1).to eq "9 34 240 116 223 241 197 129 100 82\n"
    end

    it 'should generate all distinct numbers' do
      res1 = run(['--seed', SEED] + %w[--distinct 256:0:255])
      res2 = run(['--escaped', '--seed', ESCAPED_SEED] + %w[--distinct 256:0:255])
      expect(res1).to eq res2
      results = res1.chomp.split(' ').map(&:to_i).inject({}) do |memo, arg|
        memo[arg] ||= 0
        memo[arg] += 1
        memo
      end
      (0..255).each do |i|
        expect(results[i]).to eq 1
      end
    end

    it 'should generate non-distinct numbers with just a high range' do
      res1 = run(['--seed', SEED] + %w[--choose 10:256])
      res2 = run(['--escaped', '--seed', ESCAPED_SEED] + %w[--choose 10:256])
      expect(res1).to eq res2
      expect(res1).to eq "163 124 102 221 238 64 178 43 30 126\n"
    end

    it 'should generate non-distinct numbers with a high and low range' do
      res1 = run(['--seed', SEED] + %w[--choose 10:256])
      res2 = run(['--escaped', '--seed', ESCAPED_SEED] + %w[--choose 10:256])
      expect(res1).to eq res2
      expect(res1).to eq "163 124 102 221 238 64 178 43 30 126\n"
    end

    it 'should generate all non-distinct numbers in range' do
      res1 = run(['--seed', SEED] + %w[--choose 100000:0:255])
      res2 = run(['--escaped', '--seed', ESCAPED_SEED] + %w[--choose 100000:0:255])
      expect(res1).to eq res2
      results = res1.chomp.split(' ').map(&:to_i).inject({}) do |memo, arg|
        memo[arg] ||= 0
        memo[arg] += 1
        memo
      end
      (0..255).each do |i|
        expect(results[i]).to_not be nil
        expect(results[i]).to_not eq 0
      end
    end

    it 'should generate all non-distinct numbers in range with a CSPRNG' do
      res = run(['--random-seed'] + %w[--choose 100000:0:255])
      results = res.chomp.split(' ').map(&:to_i).inject({}) do |memo, arg|
        memo[arg] ||= 0
        memo[arg] += 1
        memo
      end
      (0..255).each do |i|
        expect(results[i]).to_not be nil
        expect(results[i]).to_not eq 0
      end
    end

    it 'should generate expected items in named sets' do
      sets = [
        [:alphanumeric, "hX45LbDUah"],
        [:base64, "ol13PXvAgoplNA=="],
        [:url64, "ol13PXvAgoplNA"],
        [:"url64-padded", "ol13PXvAgoplNA=="],
        [:hex, "a25d773d7bc0828a6534"],
        [:uuid,
         %w[a25d773d-7bc0-428a-a534-705ddc3c3b32
            ed47fddf-3f60-44cc-b186-96792a1b5309
            1db11d35-7d7a-4969-a31c-94ef53eb0a09
            c85e7b7c-eaa7-4265-83ec-1b5098d73e8e
            68b4dca3-e17d-4a7a-b37b-6145335c56bd
            1b4282eb-cfe9-4ade-8a28-cafa46ebf9b2
            db84ef31-b5a9-4c1a-b9c6-7f196059478a
            b7122f8a-3a1e-475c-823c-c2257d97ace3
            09e8ab45-07e3-4df2-ae58-28c3a07cae6e
            df6da58a-c031-44de-ba9a-6a299b2001c9].join(' ')
        ],
      ]
      sets.each do |sym, res|
        res1 = run(['--seed', SEED, '--named-set', "10:#{sym}"])
        res2 = run(['--escaped', '--seed', ESCAPED_SEED, '--named-set', "10:#{sym}"])
        expect(res1).to eq res2
        expect(res1).to eq "#{res}\n"
      end
    end

    it 'should generate all items in named sets' do
      sets = [
        [:alphanumeric, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"],
        [:base64, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="],
        [:url64, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"],
        [:"url64-padded", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_="],
        [:hex, "0123456789abcdef"],
      ]
      sets.each do |sym, set|
        res1 = run(['--seed', SEED, '--named-set', "100000:#{sym}"])
        res2 = run(['--escaped', '--seed', ESCAPED_SEED, '--named-set', "100000:#{sym}"])
        res3 = run(['--random-seed', '--named-set', "100000:#{sym}"])
        expect(res1).to eq res2

        results = res1.chomp.chars.inject({}) do |memo, arg|
          memo[arg] ||= 0
          memo[arg] += 1
          memo
        end
        results_rand = res3.chomp.chars.inject({}) do |memo, arg|
          memo[arg] ||= 0
          memo[arg] += 1
          memo
        end
        set.chars.each do |i|
          expect(results[i]).to_not be nil
          expect(results[i]).to_not eq 0

          expect(results_rand[i]).to_not be nil
          expect(results_rand[i]).to_not eq 0
        end
      end
    end

    it 'should generate expected items in sets' do
      sets = [
        ["ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", "hX45LbDUah"],
        ["ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_", "i21d97BsgK"],
        ["0123456789abcdef", "2ad577d3b7"],
      ]
      sets.each do |chars, res|
        res1 = run(['--seed', SEED, '--set', "10:#{chars}"])
        res2 = run(['--escaped', '--seed', ESCAPED_SEED, '--set', "10:#{chars}"])
        expect(res1).to eq res2
        expect(res1).to eq "#{res}\n"
      end
    end

    it 'should generate expected items in escaped sets' do
      sets = [
        ["ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", "hX45LbDUah"],
        ["ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_", "i21d97BsgK"],
        ["0123456789abcdef", "2ad577d3b7"],
        ["\x00\x01\xfe\xff", "\xfe\x00\xfe\xfe\x01\xff\x01\x01\xff\x01".force_encoding("ASCII-8BIT")],
      ]
      sets.each do |chars, res|
        chars = chars.each_byte.map { |c| "\\x%02x" % c }.join
        res1 = run(['--seed', SEED, '--escaped-set', "10:#{chars}"])
        res2 = run(['--escaped', '--seed', ESCAPED_SEED, '--escaped-set', "10:#{chars}"])
        expect(res1).to eq res2
        expect(res1).to eq "#{res}\n"
      end
    end

    it 'should generate all items in sets' do
      sets = [
        [false, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"],
        [false, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"],
        [false, "0123456789abcdef"],
        [true, "\x00\x01\xfe\xff"],
        [true, (0..255).map { |b| b.chr("ASCII-8BIT") }.join],
      ]
      sets.each do |only_escaped, set|
        [true, false].each do |escape|
          next if !escape && only_escaped
          chosen_set = escape ? set.each_byte.map { |c| "\\x%02x" % c }.join : set
          arg = escape ? "--escaped-set" : "--set"
          res1 = run(['--seed', SEED, arg, "100000:#{chosen_set}"])
          res2 = run(['--escaped', '--seed', ESCAPED_SEED, arg, "100000:#{chosen_set}"])
          res3 = run(['--random-seed', arg, "100000:#{chosen_set}"])
          expect(res1).to eq res2

          results = res1.chomp.chars.inject({}) do |memo, arg|
            memo[arg] ||= 0
            memo[arg] += 1
            memo
          end
          results_rand = res3.chomp.chars.inject({}) do |memo, arg|
            memo[arg] ||= 0
            memo[arg] += 1
            memo
          end
          set.each_byte do |c|
            i = c.chr("ASCII-8BIT")
            expect(results[i]).to_not be nil
            expect(results[i]).to_not eq 0

            expect(results_rand[i]).to_not be nil
            expect(results_rand[i]).to_not eq 0
          end
        end
      end
    end

    it 'should generate expected items in bytes' do
      res1 = run(['--seed', SEED, '--bytes', '10'])
      res2 = run(['--escaped', '--seed', ESCAPED_SEED, '--bytes', '10'])
      expect(res1).to eq res2
      expect(res1).to eq "\xa2]w={\xc0\x82\x8ae4".force_encoding("ASCII-8BIT")
    end

    it 'should generate all bytes' do
      res1 = run(['--seed', SEED] + %w[--bytes 100000])
      res2 = run(['--escaped', '--seed', ESCAPED_SEED] + %w[--bytes 100000])
      res3 = run(['--escaped', '--seed-from-stdin'] + %w[--bytes 100000], stdin: ESCAPED_SEED)
      res4 = run(['--seed-from-stdin'] + %w[--bytes 100000], stdin: SEED)
      res5 = run(['--random-seed'] + %w[--bytes 100000])
      expect(res1).to eq res2
      results = res1.each_byte.inject({}) do |memo, arg|
        c = arg.chr("ASCII-8BIT")
        memo[c] ||= 0
        memo[c] += 1
        memo
      end
      stdin_results = res3.each_byte.inject({}) do |memo, arg|
        c = arg.chr("ASCII-8BIT")
        memo[c] ||= 0
        memo[c] += 1
        memo
      end
      escaped_stdin_results = res4.each_byte.inject({}) do |memo, arg|
        c = arg.chr("ASCII-8BIT")
        memo[c] ||= 0
        memo[c] += 1
        memo
      end
      random_results = res5.each_byte.inject({}) do |memo, arg|
        c = arg.chr("ASCII-8BIT")
        memo[c] ||= 0
        memo[c] += 1
        memo
      end
      (0..255).each do |c|
        i = c.chr("ASCII-8BIT")
        expect(results[i]).to_not be nil
        expect(results[i]).to_not eq 0

        expect(stdin_results[i]).to_not be nil
        expect(stdin_results[i]).to_not eq 0

        expect(escaped_stdin_results[i]).to_not be nil
        expect(escaped_stdin_results[i]).to_not eq 0

        expect(random_results[i]).to_not be nil
        expect(random_results[i]).to_not eq 0
      end
    end
  end
end
