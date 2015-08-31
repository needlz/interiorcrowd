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
      @requestPromocode()

  @bindPromocodeInput: ->
    $(@inputSelector).change =>
      $(@messagesSelector).hide()

  @requestPromocode: ->
    code = trimedVal($(@inputSelector))
    $.ajax(
      data: {
        code: code
      }
      url: '/promocodes'
      type: 'GET'
      dataType: 'json'
      success: (response)=>
        @processPromocodeResponse(response)
      error: =>
        $(@messagesSelector).hide()
        $(@requestErrorMsgSelector).show()
    )

  @processPromocodeResponse: (response)->
    @hidePreviousMessages()
    if response.valid
      @notifyPromocodeValid(response.profit)
      @applyPromocodeToPrice(response.discount)
    else
      @notifyPromocodeInvalid()
    @bindApplyPromocodeButton()

  @hidePreviousMessages: ->
    $(@messagesSelector).hide()

  @notifyPromocodeValid: (profit)->
    I18n.translations = { en: signupI18n }
    $(@validMsgSelector).show().text(I18n.t('promocode_valid', { profit: profit }))

  @applyPromocodeToPrice: (responseDiscount)->
    @displayDiscountValue(responseDiscount)
    @displayTotalValue()

  @notifyPromocodeInvalid: ->
    $(@errorMsgSelector).show().text(signupI18n.promocode_invalid)

  @displayDiscountValue: (discount)->
    $('.promotion-code-discount').text('$ ' + discount.toFixed(1))

  @displayTotalValue: ->
    discount = @extractNumber($(@promotionValueSelector))
    price = @extractNumber($(@orderTotalValueSelector))
    $(@totalPriceValueSelector).text('$ ' + (price - discount).toFixed(1))

  @extractNumber: ($element)->
    $element.text().replace(/[^\d\.]/g, '')
