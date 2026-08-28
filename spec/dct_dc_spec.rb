require_relative 'spec_helper'

describe :dct_dc do
  before(:all) do
    @dir = TestDir.new
  end

  context 'math functions' do
    it 'should generate expected output for small integers' do
      input = "1 2+p1 2-p3 7*p8 2/p"
      expect(@dir.stream(['bin/dct-dc'], input)).to eq "3\n-1\n21\n4\n"
    end

    it 'truncates division properly' do
      input = "7 2/p"
      expect(@dir.stream(['bin/dct-dc'], input)).to eq "3\n"
    end

    it 'compute fractional division properly' do
      input = "12k 1 2/p"
      expect(@dir.stream(['bin/dct-dc'], input)).to eq ".500000000000\n"
    end

    it 'computes SHA-2 constants properly' do
      primes = [2, 3, 5, 7, 11, 13, 17, 19]
      input = primes.map { |p| "20k 16o #{p}v d0k1/- 2 64^* 1/p"  }.join
      expect(@dir.stream(['bin/dct-dc'], input)).to eq <<~EOM
      6A09E667F3BCC908
      BB67AE8584CAA73B
      3C6EF372FE94F82B
      A54FF53A5F1D36F1
      510E527FADE682D1
      9B05688C2B3E6C1F
      1F83D9ABFB41BD6B
      5BE0CD19137E2179
      EOM

      input = primes.map { |p| "20k 16o #{p}v d0k1/- 2 32^* 1/p"  }.join
      expect(@dir.stream(['bin/dct-dc'], input)).to eq <<~EOM
      6A09E667
      BB67AE85
      3C6EF372
      A54FF53A
      510E527F
      9B05688C
      1F83D9AB
      5BE0CD19
      EOM
    end

    it 'computes comparisons properly' do
      expect(@dir.stream(['bin/dct-dc'], "[[ok]p]sa 1 2>a")).to eq "ok\n"
      expect(@dir.stream(['bin/dct-dc'], "[[ok]p]sa 2 1<a")).to eq "ok\n"
      expect(@dir.stream(['bin/dct-dc'], "[[ok]p]sa 0.05 1>a")).to eq "ok\n"
    end

    it 'implements loops properly' do
      expect(@dir.stream(['bin/dct-dc'], "5 [p1-d0<a]sa lax")).to eq "5\n4\n3\n2\n1\n"
      expect(@dir.stream(['bin/dct-dc'], "5 [p1-d0>blax]sa [,lc-Q]sb ,sc lax")).to eq "5\n4\n3\n2\n1\n0\n"
    end

    it 'implements q properly' do
      expect(@dir.stream(['bin/dct-dc'], "5pq2p")).to eq "5\n"
      expect(@dir.stream(['bin/dct-dc'], "[5pq2p]sa lax 3p")).to eq "5\n"
      expect(@dir.stream(['bin/dct-dc'], "[5pq2p]sa [lax]sb lbx 3p")).to eq "5\n3\n"
    end

    it 'implements trivial counting properly' do
      input = <<~EOM
      [
      Sx
      lx[
      lx 0 0SA [LA1+SA]SB <B LA  0LBX+d-K+k
      [, lD- Q]sE 0 =Elxp Xd-K+k
      lx 1 -sx
       lCx
      ]SC []SE ,SD lCx  0LCX+LDX+LEX+d-K+k
       0LxX+d-K+k
      ]St
      3 ltxp
      EOM
      expect(@dir.stream(['bin/dct-dc'], input)).to eq "3\n2\n1\n3\n"
    end

    it 'computes powers properly' do
      # TODO: positive and negative powers
    end
  end
end
