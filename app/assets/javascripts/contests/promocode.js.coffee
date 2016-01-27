class @Promocode

  @applyButtonSelector: '.apply-promocode-button'
  @inputSelector: 'input[name="client[promocode]"]'
  @errorMsgSelector: '#promocode-error'
  @requestErrorMsgSelector: '#promocode-request-error'
  @validMsgSelector: '#promocode-valid'
  @messagesSelector: '#promocode-valid, #promocode-error, #promocode-request-error'
  @orderTotalValueSelector: '.order-total-value'
  @totalPriceValueSelector: '.big-total-price'
  @promotionValueSelector: '.promotion-code-discount'

  @init: =>
    @bindApplyPromocodeButton()
    @bindPromocodeInput()

  @bindApplyPromocodeButton: ->
    $applyButton = $(@applyButtonSelector)
    $applyButton.one 'click', (event)=>
      event.preventDefault()
      code = @code()
      if code
        @requestPromocode(code)
      else
        @applyPromocodeToPrice(0)
        @bindApplyPromocodeButton()

  @bindPromocodeInput: ->
    $(@inputSelector).change =>
      $(@messagesSelector).hide()

  @code: ->
    trimedVal($(@inputSelector))

  @requestPromocode: (code)->
    $.ajax(
      data: {
        code: code
      }
      url: '/promocodes'
      type: 'GET'
      dataType: 'json'
      success: (response)=>
        @processPromocodeResponse(response)
        @bindApplyPromocodeButton()
      error: =>
        $(@messagesSelector).hide()
        $(@requestErrorMsgSelector).show()
        @bindApplyPromocodeButton()
    )

  @processPromocodeResponse: (response)->
    @hidePreviousMessages()
    if response.valid
      @notifyPromocodeValid(response.display_message)
      @applyPromocodeToPrice(response.discount)
    else
      @notifyPromocodeInvalid()
      @applyPromocodeToPrice(0)

  @hidePreviousMessages: ->
    $(@messagesSelector).hide()

  @notifyPromocodeValid: (displayMessage)->
    $(@validMsgSelector).show().text(displayMessage)

  @applyPromocodeToPrice: (responseDiscount)->
    @displayDiscountValue(responseDiscount)
    @displayTotalValue()

  @notifyPromocodeInvalid: ->
    $(@errorMsgSelector).show().text(signupI18n.promocode_invalid)

  @displayDiscountValue: (discount)->
    $('.promotion-code-discount').text('$ ' + discount.toFixed(2))

  @displayTotalValue: ->
    discount = @extractNumber($(@promotionValueSelector))
    price = @extractNumber($(@orderTotalValueSelector))
    $(@totalPriceValueSelector).text('$ ' + (price - discount).toFixed(2))

  @extractNumber: ($element)->
    $element.text().replace(/[^\d\.]/g, '')
