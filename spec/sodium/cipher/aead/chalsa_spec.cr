require "../../../spec_helper"
require "../../../../src/sodium/cipher/aead/chalsa"

combined_test_vectors = [
  {
    key:       "1b27556473e985d462cd51197a9a46c76009549eac6474f206c4ee0844f68389",
    nonce:     "69696ee955b62b73cd62bda875fc73d68219e0036b7a0b37",
    plaintext: "be075fc53c81f2d5cf141316ebeb0c7b5228c52a4c62cbd44b66849b64244ffce5e" \
               "cbaaf33bd751a1ac728d45e6c61296cdc3c01233561f41db66cce314adb310e3be8" \
               "250c46f06dceea3a7fa1348057e2f6556ad6b1318a024a838f21af1fde048977eb4" \
               "8f59ffd4924ca1c60902e52f0a089bc76897040e082f937763848645e0705",
    ciphertext: "f3ffc7703f9400e52a7dfb4b3d3305d98e993b9f48681273c29650ba32fc76ce483" \
                "32ea7164d96a4476fb8c531a1186ac0dfc17c98dce87b4da7f011ec48c97271d2c2" \
                "0f9b928fe2270d6fb863d51738b48eeee314a7cc8ab932164548e526ae902243685" \
                "17acfeabd6bb3732bc0e9da99832b61ca01b6de56244a9e88d5f9b37973f622a43d" \
                "14a6599b1f654cb45a74e355a5",
  },
]

private def box_from_test_vector(vec)
  box = Sodium::SecretBox.new vec[:key].hexbytes
  nonce = Sodium::Nonce.new vec[:nonce].hexbytes
  plaintext = vec[:plaintext].hexbytes
  ciphertext = vec[:ciphertext].hexbytes

  {box, nonce, plaintext, ciphertext}
end

{% for name in %w(XChaCha20Poly1305Ietf) %}
# TODO: verify against test vectors.
  describe Sodium::Cipher::Aead::{{ name.id }} do
    it "encrypts/decrypts in combined mode" do
      box = Sodium::Cipher::Aead::{{ name.id }}.new

      message = "foo"
      additional = "bar"
      encrypted, nonce = box.encrypt message, additional: additional
      decrypted = box.decrypt_string encrypted, nonce: nonce, additional: additional
      decrypted.should eq message

      # Wrong additional.
      expect_raises(Sodium::Error::DecryptionFailed) do
        box.decrypt encrypted, nonce: nonce, additional: "baz".to_slice
      end

      # Missing additional.
      expect_raises(Sodium::Error::DecryptionFailed) do
        box.decrypt encrypted, nonce: nonce
      end

      # Wrong data.
      expect_raises(Sodium::Error::DecryptionFailed) do
        box.decrypt "badmsgbadmsgbadmsgbadmsgbadmsg".to_slice, nonce: nonce
      end
    end

    it "encrypts/decrypts in detached mode" do
      box = Sodium::Cipher::Aead::{{ name.id }}.new

      message = "foo"
      additional = "bar"
      mac, encrypted, nonce = box.encrypt_detached message, additional: additional
      decrypted = box.decrypt_detached_string encrypted, nonce: nonce, mac: mac, additional: additional
      decrypted.should eq message

      # Wrong additional.
      expect_raises(Sodium::Error::DecryptionFailed) do
        box.decrypt_detached encrypted, nonce: nonce, mac: mac, additional: "baz".to_slice
      end

      # Missing additional.
      expect_raises(Sodium::Error::DecryptionFailed) do
        box.decrypt_detached encrypted, nonce: nonce, mac: mac
      end

      # Wrong data.
      expect_raises(Sodium::Error::DecryptionFailed) do
        box.decrypt_detached "badmsgbadmsgbadmsgbadmsgbadmsg".to_slice, nonce: nonce, mac: mac
      end
    end

    it "can't encrypt twice using the same nonce" do
      box = Sodium::Cipher::Aead::{{ name.id }}.new

      message = "foo"
      mac, encrypted, nonce = box.encrypt_detached message

      expect_raises(Sodium::Nonce::Error::Reused) do
        box.encrypt_detached message.to_slice, nonce: nonce
      end
    end
  end
{% end %}

{% if false %}
  describe Sodium::Cipher::Aead do
    it "PyNaCl combined test vectors" do
      combined_test_vectors.each do |vec|
        box, nonce, plaintext, ciphertext = box_from_test_vector vec

        encrypted, _ = box.encrypt plaintext, nonce: nonce
        encrypted.should eq ciphertext

        decrypted = box.decrypt encrypted, nonce: nonce
        plaintext.should eq decrypted
      end
    end

    pending "detached test vectors" do
      detached_test_vectors.each do |vec|
        box, nonce, plaintext, ciphertext = box_from_test_vector vec

        encrypted = box.encrypt_detached plaintext, nonce
        encrypted.should eq ciphertext

        decrypted = box.decrypt_detached encrypted, nonce
        plaintext.should eq decrypted
      end
    end
  end
{% end %}
