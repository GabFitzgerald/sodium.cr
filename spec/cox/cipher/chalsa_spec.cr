require "../../spec_helper"
require "../../../src/cox/cipher/chalsa"

{% for name in %w(XSalsa20 Salsa20 XChaCha20 ChaCha20Ietf ChaCha20) %}
# TODO: verify against test vectors.
  describe Cox::Cipher::{{ name.id }} do
    it "xors" do
      data = Bytes.new(100)
      cipher1 = Cox::Cipher::{{ name.id }}.new
      cipher2 = Cox::Cipher::{{ name.id }}.new
      key = cipher1.random_key
      nonce = cipher1.random_nonce
      output = cipher1.update data
      cipher1.update(data).should_not eq output # Verify offset is incremented.
      cipher1.final.should eq Bytes.new(0)

      cipher2.key = key
      cipher2.nonce = nonce
      cipher2.update(output).should eq data
    end
  end
{% end %}
