module ImageItemAttributeValueRenderers

  class Price < Base

    def to_s
      view_context.humanized_money_with_symbol(value)
    end

  end

end

