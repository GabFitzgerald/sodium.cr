require "random/secure"

module Sodium
  class Error < ::Exception
    class VerificationFailed < Error
    end

    class DecryptionFailed < Error
    end
  end

  def self.memzero(bytes : Bytes)
    LibSodium.sodium_memzero bytes, bytes.bytesize
  end
end

require "./sodium/**"

if Sodium::LibSodium.sodium_init == -1
  abort "Failed to init libsodium"
end
