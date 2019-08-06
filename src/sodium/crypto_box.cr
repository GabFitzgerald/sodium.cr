require "./lib_sodium"
require "./wipe"
require "./crypto_box/secret_key"
require "./nonce"

module Sodium
  class CryptoBox
    include Wipe

    MAC_SIZE = LibSodium.crypto_box_macbytes.to_i

    # BUG: precompute size
    @[Wipe::Var]
    @bytes = Bytes.new(1)

    def initialize(@secret_key : SecretKey, @public_key : PublicKey)
      # TODO: precompute using crypto_box_beforenm
    end

    # Encrypts data and returns {ciphertext, nonce}
    def encrypt(src)
      encrypt src.to_slice
    end

    # Encrypts data and returns {ciphertext, nonce}
    #
    # Optionally supply a destination buffer.
    def encrypt(src : Bytes, dst = Bytes.new(src.bytesize + MAC_SIZE), nonce = Nonce.new) : {Bytes, Nonce}
      if LibSodium.crypto_box_easy(dst, src, src.bytesize, nonce.to_slice, @public_key.to_slice, @secret_key.to_slice) != 0
        raise Error.new("crypto_box_easy")
      end
      {dst, nonce}
    end

    # Returns decrypted message.
    #
    def decrypt(src)
      decrypt src.to_slice
    end

    # Returns decrypted message.
    #
    # Optionally supply a destination buffer.
    def decrypt(src : Bytes, dst = Bytes.new(src.bytesize - MAC_SIZE), nonce = Nonce.new) : Bytes
      if LibSodium.crypto_box_open_easy(dst, src, src.bytesize, nonce.to_slice, @public_key.to_slice, @secret_key.to_slice) != 0
        raise Error::DecryptionFailed.new("crypto_box_open_easy")
      end
      dst
    end

    # TODO detached
  end
end
