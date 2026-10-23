require_relative 'spec_helper'

describe :dct_dc do
  before(:all) do
    @dir = TestDir.new
    # Generated from `randomgen --seed dct-dc --named-set 32:hex`, with decimal
    # points added in different places.
    @val1 = "AC6EA2FE97461EA4B4BCB9D5.69F14B21"
    @val2 = "189C851B74EF4C676529329B1BA6.23BB"
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

    it 'computes remainders properly' do
      # GNU dc documents that % is the same as the sequence Sd dld/ Ld*-.
      a = [4, -4, 2, -2]
      b = [2, -2, 1, -1]
      input = []
      a.each do |av|
        b.each do |bv|
          numbers = "#{av.to_s.tr('-', '_')} #{bv.to_s.tr('-', '_')}"
          input << "#{numbers} % #{numbers} Sd dld/ Ld*-Gp"
        end
      end
      expect(@dir.stream(['bin/dct-dc'], input.join)).to eq ("1\n" * input.length)
    end

    it 'computes arithmetic with the correct precision' do
      input = "2.3 5.12+ 2.3 5.12- 2.3 5.12* 4k 2.3 5.12* 0k 3 2/ 1k 3 2/f"
      expect(@dir.stream(['bin/dct-dc'], input)).to eq "1.5\n1\n11.776\n11.77\n-2.82\n7.42\n"
    end

    it "processes simple Forth functions correctly" do
      mathlib = @dir.stream(['bin/dct-dc', "--compile", ".local/share/dct-dc/math/example.fth"], "")

      expect(@dir.stream(['bin/dct-dc'], "#{mathlib} 3ltx")).to eq "3\n2\n1\n"
    end

    it 'computes SHA-2 constants properly' do
      primes = [2, 3, 5, 7, 11, 13, 17, 19]
      input = primes.map { |p| "20k 16o #{p}v d0k1/- 2 64^* 1/p"  }.join
      expected = <<~EOM
      6A09E667F3BCC908
      BB67AE8584CAA73B
      3C6EF372FE94F82B
      A54FF53A5F1D36F1
      510E527FADE682D1
      9B05688C2B3E6C1F
      1F83D9ABFB41BD6B
      5BE0CD19137E2179
      EOM
      expect(@dir.stream(['bin/dct-dc'], input)).to eq expected
      input = primes.map { |p| "20k 16o #{p}.0000000v d0k1/- 2 64^* 1/p"  }.join
      expect(@dir.stream(['bin/dct-dc'], input)).to eq expected

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

    it 'computes comparisons and booleans properly' do
      [
        [1, 2, %w[> !< !=], %w[< !> =], %w[) } GN], %w[( { G]],
        [2, 1, %w[< !> !=], %w[> !< =], %w[( { GN], %w[) } G]],
        [2, 2, %w[= !> !<], %w[> < !=], %w[{ } G], %w[( ) GN]],
        [0.05, 1, %w[> !< !=], %w[< !> =], %w[) } GN], %w[( { G]],
      ].each do |(a, b, truecmp, falsecmp, truebin, falsebin)|
        truecmp.each do |cmp|
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]sa #{a} #{b} #{cmp}a")).to eq "ok\n"
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]s abc #{a} #{b} #{cmp} abc")).to eq "ok\n"
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]sa [[false]f]sb #{a} #{b} #{cmp}aeb")).to eq "ok\n"
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]s abc [[false]f]s def #{a} #{b} #{cmp} abc e def")).to eq "ok\n"
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]sa [[false]f]s def #{a} #{b} #{cmp}ae def")).to eq "ok\n"
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]s abc [[false]f]sd #{a} #{b} #{cmp} abc ed")).to eq "ok\n"
        end
        falsecmp.each do |cmp|
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]sa #{a} #{b} #{cmp}a")).to eq ""
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]s abc #{a} #{b} #{cmp} abc")).to eq ""
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]sa [[false]f]sb #{a} #{b} #{cmp}aeb")).to eq "false\n"
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]s abc [[false]f]s def #{a} #{b} #{cmp} abc e def")).to eq "false\n"
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]sa [[false]f]s def #{a} #{b} #{cmp}ae def")).to eq "false\n"
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]s abc [[false]f]sd #{a} #{b} #{cmp} abc ed")).to eq "false\n"
        end
        truebin.each do |cmp|
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]sa #{a} #{b} #{cmp} 1=a")).to eq "ok\n"
        end
        falsebin.each do |cmp|
          expect(@dir.stream(['bin/dct-dc'], "[[ok]f]sa #{a} #{b} #{cmp} 0=a")).to eq "ok\n"
        end
      end
      [
        [0, 0, false, false],
        [0, 1, false, true],
        [1, 0, false, true],
        [1, 1, true, true],
        ["[abc]", 6, true, true],
      ].each do |(a, b, andop, orop)|
        expect(@dir.stream(['bin/dct-dc'], "[[ok]p]sa #{a} #{b} M 1=a")).to eq (andop ? "ok\n" : "")
        expect(@dir.stream(['bin/dct-dc'], "[[ok]p]sa #{a} #{b} m 1=a")).to eq (orop ? "ok\n": "")
      end
    end

    it 'implements loops properly' do
      expect(@dir.stream(['bin/dct-dc'], "5 [p1-d0<a]sa lax")).to eq "5\n4\n3\n2\n1\n"
      expect(@dir.stream(['bin/dct-dc'], "5 [p1-d0>blax]sa [,lc-Q]sb ,sc lax")).to eq "5\n4\n3\n2\n1\n0\n"
      expect(@dir.stream(['bin/dct-dc'], "[ln 1+ d sn p ln 10>b]sb\n0sn0\nlbx\n")).to eq (1..10).map { |n| "#{n}\n" }.join('')
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

    it 'implements the sieve of Eratosthenes properly' do
      # Source: https://web.archive.org/web/20040904170757/http://cpe000103c34069-cm014300001653.cpe.net.cable.rogers.com/weblogs/ben/programming/dc/Prime-Sieve-in-DC.writeback
      # Modified to make y smaller to avoid stack overflow.
      input = <<~EOM
      # Sieve of Eratosthenes in dc, version 1.0
      # Ben Zanin, 2004-04-23T1634h; public domain
      3sx 100000sy 0sz
      [dd :q 2+ SlSm lmll LmLl <h] sh
      ly 1+ 3 lhx sjsj 2 2:q
      [lx ;q 0 !=b lx2+sxlx ly >a] sa
      [lx p Sp ly lxd*szlz <c]     sb
      [0lz:q lxlz+sz lylz <c]      sc
      2psj
      lax
      EOM
      primes = [2]
      (3..100000).each do |n|
        next unless n.odd?
        sqrt = Integer::sqrt(n)
        idx = primes.bsearch_index { |x| x >= sqrt }
        found = false
        (0..idx).each do |x|
          if (n % primes[x]).zero?
            found = true
            break
          end
        end
        primes << n unless found
      end
      output = primes.map { |n| "#{n}\n" }.join
      expect(@dir.stream(['bin/dct-dc'], input)).to eq output
    end

    it 'does common arithmetic operations properly' do
      expect(@dir.stream(['bin/dct-dc'], "6k 16i #{@val1} #{@val2}+p")).to eq "499231983712626657269523011851643.55333809\n"
      expect(@dir.stream(['bin/dct-dc'], "6k 16i #{@val1} #{@val2}-p")).to eq "-499125253366128312040972045148624.72566191\n"
      expect(@dir.stream(['bin/dct-dc'], "6k 16i #{@val1} #{@val2}*p")).to eq "26638753460636528152813078337591935260428539533100333651201457.58253447\n"
      expect(@dir.stream(['bin/dct-dc'], "6k 16i #{@val1} #{@val2}/p")).to eq ".000106\n"
      expect(@dir.stream(['bin/dct-dc'], "6k 16i #{@val1} #{@val2}%p")).to eq "452239683998600902027113488.3996193030\n"
      expect(@dir.stream(['bin/dct-dc'], "6k 16i #{@val1} #{@val2}~f")).to eq "452239683998600902027113488.3996193030\n.000106\n"
    end

    it 'handles strings properly' do
      expect(@dir.stream(['bin/dct-dc'], "16i 6F6C6C6548dandan")).to eq "HH"
      expect(@dir.stream(['bin/dct-dc'], "16i 48656C6C6F0AP")).to eq "Hello\n"
      expect(@dir.stream(['bin/dct-dc'], "[abc]ap")).to eq "a\n"
      expect(@dir.stream(['bin/dct-dc'], "[]ap")).to eq "\n"
      expect(@dir.stream(['bin/dct-dc'], "[abc]pp")).to eq "abc\nabc\n"
      expect(@dir.stream(['bin/dct-dc'], "0[abc]nk")).to eq "abc"
      expect(@dir.stream(['bin/dct-dc'], "0[abc]Pk")).to eq "abc"
      expect(@dir.stream(['bin/dct-dc'], "0[]Pk")).to eq ""
    end

    it 'handles the stack properly' do
      expect(@dir.stream(['bin/dct-dc'], "0 1 [abc] 2 [def] 3 [ghi]f")).to eq "ghi\n3\ndef\n2\nabc\n1\n0\n"
      expect(@dir.stream(['bin/dct-dc'], "0 1 [abc] 2 [def]c 3 [ghi]f")).to eq "ghi\n3\n"
      expect(@dir.stream(['bin/dct-dc'], "0.123X 0.01234X 4.02X [abcd©]Xf")).to eq "0\n2\n5\n3\n"
      expect(@dir.stream(['bin/dct-dc'], "0.123Z 0.01234Z 4.02Z [abcd©]Zf")).to eq "6\n3\n4\n3\n"
      expect(@dir.stream(['bin/dct-dc'], "0 1 [abc] z [def] z [ghi]f")).to eq "ghi\n5\ndef\n3\nabc\n1\n0\n"
    end

    it 'handles base and scale properly' do
      expect(@dir.stream(['bin/dct-dc'], "I O Kf")).to eq "0\n10\n10\n"
      expect(@dir.stream(['bin/dct-dc'], "16o 8i 10k I O Kf")).to eq "8\n10\n8\n"
      expect(@dir.stream(['bin/dct-dc'], "8o 16i 10k I O Kf")).to eq "20\n10\n20\n"
      expect(@dir.stream(['bin/dct-dc'], "F 1+i FE Ci FE Ai FEf")).to eq "164\n194\n254\n"
      expect(@dir.stream(['bin/dct-dc'], "F 1+i .FE 1* Ci .FE 1* Ai .FE 1*f")).to eq "1.64\n1.34\n.99\n"
    end

    it 'computes exponentiation properly' do
      # TODO: positive and negative powers
      expect(@dir.stream(['bin/dct-dc'], "6k 2 31 31|p")).to eq "2\n"
      expect(@dir.stream(['bin/dct-dc'], "2 31^ 31%p")).to eq "2\n"
      # Based off an RSA test vector.  This is obviously not constant time, so
      # it's not suitable for real cryptography.
      base, e, d, mod, res = <<~EOM.chomp.split("\n")
      27DA4104EACE1991E08BD8E7CFCCD97EC48B896A0E156CE7BDC23FD570AAA9A00ED015101F0C6261C7371CECA327A73C3CECFCF6B2D9ED920C9698046E25C89ADB2360887D99983BF632F9E6EB0E5DF60715902B9AEAA74BF5027AA246510891C74AE366A16F397E2C8CCDC8BD56AA10E0D01585E69F8C4856E76B53ACFD3D782B8171529008FA5EFF030F46956704A3F5D9167348F37021FC277C6C0A8F93B8A23CFBF918990F982A56D0ED2AA08161560755ADC0CE2C3E2AB2929F79BFC0B24FF3E0FF352E6445D8A617F1785D66C32295BB365D61CFB107E9993BBD93421F2D344A86E4127827FA0D0B2535F9B1D547DE12BA2868ACDECF2CB5F92A6A159A
      00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000260445
      0997634C477C1A039D44C810B2AAA3C7862B0B88D3708272E1E15F66FC9389709F8A11F3EA6A5AF7EFFA2D01C189C50F0D5BCBE3FA272E56CFC4A4E1D388A9DCD65DF8628902556C8B6BB6A641709B5A35DD2622C73D4640BFA1359D0E76E1F219F8E33EB9BD0B59EC198EB2FCCAAE0346BD8B401E12E3C67CB629569C185A2E0F35A2F741644C1CCA5EBB139D77A89A2953FC5E30048C0E619F07C8D21D1E56B8AF07193D0FDF3F49CD49F2EF3138B5138862F1470BD2D16E34A2B9E7777A6C8C8D4CB94B4E8B5D616CD5393753E7B0F31CC7DA559BA8E98D888914E334773BAF498AD88D9631EB5FE32E53A4145BF0BA548BF2B0A50C63F67B14E398A34B0D
      CEA80475324C1DC8347827818DA58BAC069D3419C614A6EA1AC6A3B510DCD72CC516954905E9FEF908D45E13006ADF27D467A7D83C111D1A5DF15EF293771AEFB920032A5BB989F8E4F5E1B05093D3F130F984C07A772A3683F4DC6FB28A96815B32123CCDD13954F19D5B8B24A103E771A34C328755C65ED64E1924FFD04D30B2142CC262F6E0048FEF6DBC652F21479EA1C4B1D66D28F4D46EF7185E390CBFA2E02380582F3188BB94EBBF05D31487A09AFF01FCBB4CD4BFD1F0A833B38C11813C84360BB53C7D4481031C40BAD8713BB6B835CB08098ED15BA31EE4BA728A8C8E10F7294E1B4163B7AEE57277BFD881A6F9D43E02C6925AA3A043FB7FB78D
      1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00302D300D06096086480165030402040500041CC34B1A0D795DAE5B88559191BB2C1CB75A5FD1D18B5002074560E6AD
      EOM
      expect(@dir.stream(['bin/dct-dc'], "16o 16i #{base} #{e} #{mod}|p")).to eq "#{res}\n"
      expect(@dir.stream(['bin/dct-dc'], "16o 16i #{res} #{d} #{mod}|p")).to eq "#{base}\n"
    end

    it "processes comments correctly" do
      input = <<~EOM
      # 1p
      [2p#3p]x
      [# 4p
      # 5p
      6p
      ]x
      EOM
      expect(@dir.stream(['bin/dct-dc'], input)).to eq "2\n6\n"
    end
  end
end
