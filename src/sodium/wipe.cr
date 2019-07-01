module Sodium
  def self.memzero(bytes : Bytes)
    LibSodium.sodium_memzero bytes, bytes.bytesize
  end
end

module Sodium::Wipe
  annotation Var
  end

  @closed = false

  def close
    return if @closed
    wipe
    @closed = true
  end

  protected def wipe
    return if @closed

    {% for ivar in @type.instance_vars %}
      {% if ann = ivar.annotation(Wipe::Var) %}
        {% if ivar.type <= StaticArray %}
          Sodium.memzero @{{ivar.id}}.to_slice
        {% else %}
          case var = @{{ ivar.id }}
          when Slice
            Sodium.memzero var
          when nil
          else
            raise "unsupported wipe type for #{typeof(@{{ ivar.id }})} {{ ivar.id }}"
          end
        {% end %}
      {% end %}
    {% end %}
  end

  def finalize
    wipe # Don't call close.  May be overridden with calls unsafe within finalize.
  end
end
