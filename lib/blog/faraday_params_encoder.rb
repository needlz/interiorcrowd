module Blog

  class FaradayParamsEncoder

    def self.encode(params)
      return nil if params == nil

      if !params.is_a?(Array)
        if !params.respond_to?(:to_hash)
          raise TypeError,
                "Can't convert #{params.class} into Hash."
        end
        params = params.to_hash
        params = params.map do |key, value|
          key = key.to_s if key.kind_of?(Symbol)
          [key, value]
        end
      end

      # Helper lambda
      to_query = lambda do |parent, value|
        if value.is_a?(Hash)
          value = value.map do |key, val|
            key = escape(key)
            [key, val]
          end
          value.sort!
          buffer = ""
          value.each do |key, val|
            new_parent = "#{parent}%5B#{key}%5D"
            buffer << "#{to_query.call(new_parent, val)}&"
          end
          return buffer.chop
        elsif value.is_a?(Array)
          buffer = ""
          value.each_with_index do |val, i|
            new_parent = "#{parent}%5B%5D"
            buffer << "#{to_query.call(new_parent, val)}&"
          end
          return buffer.chop
        else
          encoded_value = escape(value)
          return "#{parent}=#{encoded_value}"
        end
      end

      # The params have form [['key1', 'value1'], ['key2', 'value2']].
      buffer = ''
      params.each do |parent, value|
        encoded_parent = escape(parent)
        buffer << "#{to_query.call(encoded_parent, value)}&"
      end
      return buffer.chop
    end

    def self.escape(s)
      s.to_s.gsub(Faraday::Utils::ESCAPE_RE) {|match|
        '%' + match.unpack('H2' * match.bytesize).join('%').upcase
      }.tr(' ', '+')
    end

  end

end
