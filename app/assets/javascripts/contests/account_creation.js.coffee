trimedVal = ($input)->
  $.trim($input.val())

class Promocode

  @applyButtonSelector: '.apply-promocode-button'
  @inputSelector: 'input[name="client[promocode]"]'
  @errorMsgSelector: '#promocode-error'
  @requestErrorMsgSelector: '#promocode-request-error'
  @validMsgSelector: '#promocode-valid'
  @messagesSelector: '#promocode-valid, #promocode-error, #promocode-request-error'
  @orderTotalValueSelector: '.order-total-value'
  @totalPriceValueSelector: '.big-total-price'

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

class CardValidation

  @init: ->
    @error = null
    @valid = false
    $('#card_number, #card_cvc, #client_card_ex_month, #client_card_ex_year').change (event)=>
      $("#err_card_number").text('')
      @validate()

  @validate: ->
    Stripe.card.createToken(
      {
        number: $('#card_number').val(),
        cvc: $('#card_cvc').val(),
        exp_month: $('#client_card_ex_month').val(),
        exp_year: $('#client_card_ex_year').val()
      }, (status, response) =>
        if response.error
          @error = response.error.message
          @valid = false
          $("#err_card_number").text(response.error.message)
        else
          @valid = true
    )

class AccountCreation

  @init: ->
    @validator = new ValidationMessages()
    Promocode.init()
    CardValidation.init()
    @bindSubmitButton()
    @bindAgreementCheckbox()
    @styleDropdowns()
    @bindNumericInputs()

  @bindNumericInputs: ->
    $('#card_number, #card_cvc, #client_zip').ForceNumericOnly();

  @validations: [
    ->
      $first_name = $("#client_first_name")
      if trimedVal($first_name).length < 1
        @validator.addMessage $("#err_first_name"), "Please enter first name.", $first_name
    ->
      $last_name = $("#client_last_name")
      if trimedVal($last_name).length < 1
        @validator.addMessage $("#err_last_name"), "Please enter last name.", $last_name
    ->
      $email = $("#client_email")
      email = trimedVal($email)
      if email.length > 1
        rege = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
        unless rege.test(email)
          @validator.addMessage $("#err_email"), "Please enter valid email.", $email
      else
        @validator.addMessage $("#err_email"), "Please enter email.", $email
    ->
      $password = $("#client_password")
      password = trimedVal($password)
      if password.length < 1
        @validator.addMessage $("#err_password"), "Please enter password.", $password
      $c_password = $("#client_password_confirmation")
      c_password = trimedVal($c_password)
      if c_password.length < 1
        @validator.addMessage $("#err_cpassword"), "Please enter confirm password.", $c_password
      else
        unless c_password is password
          @validator.addMessage $("#err_cpassword"), "Password and Confirm password must be same.", $c_password
    ->
      $name_on_card = $("#client_name_on_card")
      if trimedVal($name_on_card).length < 1
        @validator.addMessage $("#err_name_on_card"), "Please enter name.", $name_on_card
    ->
      $address = $("#client_billing_address")
      if trimedVal($address).length < 1
        @validator.addMessage $("#err_address"), "Please enter address.", $address
    ->
      $state = $("#client_billing_state")
      state = trimedVal($state)
      if state.length > 1
        rege = /^[a-zA-Z]+$/
        unless rege.test(state)
          @validator.addMessage $("#err_state"), "Please enter valid state. Only letters are allowed.", $state
      else
        @validator.addMessage $("#err_state"), "Please enter state.", $state
    ->
      $zip = $("#client_billing_zip")
      zip = trimedVal($zip)
      if zip.length > 1
        unless $.isNumeric(zip)
          @validator.addMessage $("#err_zip"), "Please enter valid zip.", $zip
      else
        @validator.addMessage $("#err_zip"), "Please enter zip.", $zip
    ->
      unless $('#client_agree').is(':checked')
        @validator.valid = false
    ->
      unless CardValidation.valid
        if CardValidation.error
          @validator.addMessage $("#err_card_number"), CardValidation.error, $cardNumber
        else
          $cardNumber = $("#card_number")
          if (trimedVal($cardNumber).length < 1) && $("#err_card_number").text().length < 1
            @validator.addMessage $("#err_card_number"), "Please enter card number.", $cardNumber
        @validator.valid = false
  ]

  @validate: ->
    @validator.reset()
    for validation in @validations
      validation.apply @

  @bindSubmitButton: ->
    $('.submit-button').click (e) =>
      e.preventDefault()
      $('.text-error').html('')
      @validate()
      if @validator.valid
        $('#new_client [type=submit]').click()
      else
        @validator.focusOnMessage()
        false

  @bindAgreementCheckbox: ->
    $('.tick-btn').click ->
      $(this).toggleClass 'active'
      $('#client_agree').trigger 'click'

  @styleDropdowns: ->
    $('.selectpicker').selectpicker { style: 'btn-selector-medium font15' }

$(document).ready ->
  AccountCreation.init()
