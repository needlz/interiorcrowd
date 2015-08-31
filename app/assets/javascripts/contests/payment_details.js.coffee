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

class @PaymentPage

  @init: ->
    Promocode.init()
    CardValidation.init()

    $('.submit-button').click (event)=>
      event.preventDefault()
      if $('#client_agree').is(':checked')
        @form().submit()

  @form: ->
    $('#new_client_payment')

class @CreditCards

  @creditCardAreaSelector: '.credit-card-params'
  @primaryCreditCardAreaClassName: 'primary-card-params'
  @setPrimaryCardLinkSelector: 'a#card-type'
  @saveCreditCardLinkSelector: 'a#save-credit-card'
  @newCreditCardFormSelector: '.new_credit_card'
  @creditCardFromDivSelector: '.credit-card-form'
  @addNewCreditCardButtonSelector: '.add-new-credit-card'
  @cancelCardAddingButtonSelector: '#cancel-card-adding'
  @cardsContainerSelector: '.payment-info-container'

  @init: ->
    @bindCardChoosing()
    @bindAddNewCardButton()
    @bindCancelCardAdding()
    @bindCreditCardSaving()
    @styleDropdowns()


  @bindCardChoosing: ->
    $(document).on 'click', @setPrimaryCardLinkSelector, (event)=>
      cardId = $(event.target).data('id')
      $.ajax(
        url: '/credit_cards/' + cardId + '/set_as_primary',
        method: 'PATCH',
        success: =>
          @setPrimaryCard(event.target)
      )

  @bindCreditCardSaving: ->
    $(@saveCreditCardLinkSelector).on 'click', (event)=>
      $form = $(@newCreditCardFormSelector)
      $.ajax(
        url: $form.attr('action'),
        method: $form.attr('method'),
        data: $form.serializeArray()
        success: (data)=>
          @toggleCardFormVisibility()
          $firstCard = $(@creditCardAreaSelector + ':first')
          if $firstCard.length
            $(data).insertBefore($firstCard)
          else
            $(data).appendTo($(@cardsContainerSelector))
          @setDefaultInputValues()
      )

  @setDefaultInputValues: ->
    $form = $(@creditCardFromDivSelector)
    $form.find('input').val('')
    $form.find('select').prop('selectedIndex', 0).change()

  @bindCancelCardAdding: ->
    $(@cancelCardAddingButtonSelector).on 'click', (event)=>
      @toggleCardFormVisibility()

  @bindAddNewCardButton: ->
    $(@addNewCreditCardButtonSelector).on 'click', (event)=>
      @toggleCardFormVisibility()

  @toggleCardFormVisibility: ->
    $(@creditCardFromDivSelector).toggleClass('hidden')

  @setPrimaryCard: (link)->
    $(@creditCardAreaSelector).removeClass(@primaryCreditCardAreaClassName)
    $(link).closest(@creditCardAreaSelector).addClass(@primaryCreditCardAreaClassName)
    $(@creditCardAreaSelector).find(@setPrimaryCardLinkSelector).text(signupI18n.make_card_primary)
    $('.' + @primaryCreditCardAreaClassName).find(@setPrimaryCardLinkSelector).text(signupI18n.primary_card)

  @styleDropdowns: ->
    $('.selectpicker').selectpicker { style: 'btn-selector-medium font15' }

$(document).ready ->
  CreditCards.init()
