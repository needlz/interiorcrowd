class @NewGiftcardPayment

  @init: ->
    $('#giftcard_payment_quantity').selectpicker(style: 'btn-selector-medium').change (event)->
      price = getSelectedPrice()
      setAmount(price)

    setAmount = (dollars)->
      $('.contactForm .amount .dollars').text('$' + dollars)

    getSelectedPrice = ()->
      $('#giftcard_payment_quantity').find(':selected').data('price')

    setAmount(getSelectedPrice())

    stripeHandler = StripeCheckout.configure
      key: stripe_publishable_api_key,
      image: '/assets/logo.png',
      locale: 'auto',
      token: (token)->
        $form = $('#new_giftcard_payment')
        $form.find('#giftcard_payment_email').val(token.email)
        $form.find('#giftcard_payment_token').val(token.id)
        $form.submit()

    $('input[type=submit]').click (event)->
      event.preventDefault()
      price = getSelectedPrice()
      setAmount(price)
      quantity = $('#giftcard_payment_quantity').find(':selected').val()
      email = $('#giftcard_payment_email').val()
      description = "#{ quantity } giftcards ($#{ price })"

      stripeHandler.open
        name: 'InteriorCrowd'
        description: description
        amount: price * 100
        email: email
