require "benchmark"
require "../src/sodium"
require "openssl"
require "openssl/digest"

output_size = 64
sizes = [16, 64, 256, 1024, 8192, 16384]
bufs = sizes.map { |size| Bytes.new size }.to_a

puts "Compare against 'openssl speed digestname'"
puts "'crystal run --release benchmarks/blake2b.cr sha1 sha256'"

Benchmark.ips(warmup: 0.5) do |bm|
  sizes.each_with_index do |size, i|
    bm.report "blake2b new obj per iter #{size}" do
      d = Sodium::Digest::Blake2b.new 64
      d.update bufs[i]
      d.final
    end

    d = Sodium::Digest::Blake2b.new output_size
    bm.report "blake2b reset per iter #{size}" do
      d.reset
      d.update bufs[i]
      d.final
    end

    d = Sodium::Digest::Blake2b.new output_size
    dst = Bytes.new d.digest_size
    bm.report "blake2b reset reusing buffer per iter #{size}" do
      d.reset
      d.update bufs[i]
      d.final dst
    end
  end

  ARGV.each do |arg|
    sizes.each_with_index do |size, i|
      bm.report "#{arg} new obj per iter  #{size}" do
        d = OpenSSL::Digest.new arg
        d.update bufs[i]
        d.final
      end

      d = OpenSSL::Digest.new arg
      bm.report "#{arg} reset per iter #{size}" do
        d.reset
        d.update bufs[i]
        d.final
      end

      d = OpenSSL::Digest.new arg
      dst = Bytes.new d.digest_size
      bm.report "#{arg} reset reusing buffer per iterr #{size}" do
        d.reset
        d.update bufs[i]
        d.final dst
      end
    end
  end
end
