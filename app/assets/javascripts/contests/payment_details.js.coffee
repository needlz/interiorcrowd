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
        exp_month: $('#credit_card_ex_month').val(),
        exp_year: $('#credit_card_ex_year').val()
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
  @deleteCardLinkSelector: 'a#remove-card'
  @saveCreditCardLinkSelector: 'a#save-credit-card'
  @newCreditCardFormSelector: '.new_credit_card'
  @creditCardFormDivSelector: '.credit-card-form'
  @addNewCreditCardButtonSelector: '.add-new-credit-card'
  @cancelCardAddingButtonSelector: '#cancel-card-adding'
  @cardsContainerSelector: '.payment-info-container'

  @init: ->
    @bindCardChoosing()
    @bindAddNewCardButton()
    @bindCancelCardAdding()
    @bindCreditCardSaving()
    @bindCardEditing()
    @bindCardDeleting()
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

  @bindAddNewCardButton: ->
    $(@addNewCreditCardButtonSelector).on 'click', (event)=>
      @toggleCardFormVisibility()

  @bindCancelCardAdding: ->
    $(document).on 'click', @cancelCardAddingButtonSelector, (event)=>
      @toggleCardFormVisibility(event.target)

  @bindCreditCardSaving: ->
    $(document).on 'click', @saveCreditCardLinkSelector, (event)=>
      $form = $(event.target).closest(@newCreditCardFormSelector)
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

  @bindCardEditing: ->
    $(document).on 'click', 'a#edit-card', (event)=>
      cardId = $(event.target).data('id')
      $.ajax(
        url: '/credit_cards/' + cardId + '/edit',
        method: 'GET',
        success: (data)=>
          $cardContainer = $(event.target).closest('.credit-card-params')
          $cardContainer.replaceWith(data)
          @styleDropdowns()
      )

  @bindCardDeleting: ->
    $(document).on 'click', @deleteCardLinkSelector, (event)=>
      cardId = $(event.target).data('id')
      $.ajax(
        url: '/credit_cards/' + cardId,
        method: 'DELETE',
        success: =>
          $(event.target).closest('.credit-card-params').remove()
      )

  @styleDropdowns: ->
    $('.selectpicker').selectpicker { style: 'btn-selector-medium font15' }

  @setDefaultInputValues: ->
    $form = $(@creditCardFormDivSelector)
    $form.find('input').val('')
    $form.find('select').prop('selectedIndex', 0).change()

  @toggleCardFormVisibility: (editLink)->
    $form = $(editLink).closest(@creditCardFormDivSelector)
    if $form.length
      $form.remove()
    else
      $form = $(@creditCardFormDivSelector + ':first')
      $form.toggleClass('hidden')

  @setPrimaryCard: (link)->
    $(@creditCardAreaSelector).removeClass(@primaryCreditCardAreaClassName)
    $(link).closest(@creditCardAreaSelector).addClass(@primaryCreditCardAreaClassName)
    $(@creditCardAreaSelector).find(@setPrimaryCardLinkSelector).text(signupI18n.make_card_primary)
    $('.' + @primaryCreditCardAreaClassName).find(@setPrimaryCardLinkSelector).text(signupI18n.primary_card)

$(document).ready ->
  CreditCards.init()
