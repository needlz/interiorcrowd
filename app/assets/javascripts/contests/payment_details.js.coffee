class CardValidation

  @init: ->
    @error = null
    @valid = false
    $('#card_number, #card_cvc, #credit_card_ex_month, #credit_card_ex_year').change (event)=>
      $("#err_card_number").text('')
      @validate() if @allInputsFilled()

  @validate: ->
    Stripe.card.createToken(
      {
        number: $('#card_number').val(),
        cvc: $('#card_cvc').val(),
        exp_year: $('#credit_card_ex_year').val()
        exp_month: $('#credit_card_ex_month').val(),
      }, (status, response) =>
        if response.error
          @error = response.error.message
          @valid = false
          $("#err_card_number").text(response.error.message)
        else
          @valid = true
    )

  @allInputsFilled: ->
    for inputSelector in ['#card_number', '#card_cvc', '#credit_card_ex_month', '#credit_card_ex_year']
      return false unless $(inputSelector).val()
    true

class @PaymentPage

  @init: ->
    Promocode.init()
    CardValidation.init()

    $('.submit-button').click (event)=>
      event.preventDefault()
      if $('#client_agree').is(':checked')
        amount = parseFloat($(Promocode.totalPriceValueSelector).text().replace(/[^0-9\.]+/g,""))
        fbq('track', 'Purchase', { value: amount, currency: 'USD' })
        setTimeout(
          =>
            @form().submit()
          200
        )

  @form: ->
    $('#new_client_payment')

class @CreditCards

  @creditCardAreaSelector: '.credit-card-params'
  @primaryCreditCardAreaClassName: 'primary-card-params'
  @setPrimaryCardLinkSelector: 'a.set-primary'
  @deleteCardLinkSelector: 'a#remove-card'
  @saveCreditCardLinkSelector: 'a#save-credit-card'
  @newCreditCardFormSelector: '.new_credit_card'
  @editCreditCardFormSelector: 'edit_credit_card'
  @creditCardFormDivSelector: '.credit-card-form'
  @addNewCreditCardButtonSelector: '.add-new-credit-card'
  @cancelCardAddingButtonSelector: '#cancel-card-adding'
  @cardsContainerSelector: '.first-card-container'
  @errorMessageContainer: '#credit-card-editing-error'

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
      unless $form.length
        $form = $(event.target).closest('.' + @editCreditCardFormSelector)
        $form.attr('method', $('[name=_method]').val())
        @performRequest $form, @displayUpdatedCardInfo, event.target
      else
        @performRequest $form, @displayNewlyAddedCard

  @bindCardEditing: ->
    $(document).on 'click', 'a#edit-card', (event)=>
      cardId = $(event.target).data('id')
      $.ajax(
        url: '/credit_cards/' + cardId + '/edit',
        method: 'GET',
        success: (data)=>
          $cardContainer = $(event.target).closest(@creditCardAreaSelector)
          $cardContainer.hide()
          $(data).insertBefore($cardContainer)
          @styleDropdowns()
      )

  @bindCardDeleting: ->
    $(document).on 'click', @deleteCardLinkSelector, (event)=>
      cardId = $(event.target).data('id')
      $.ajax(
        url: '/credit_cards/' + cardId,
        method: 'DELETE',
        success: =>
          $(event.target).closest(@creditCardAreaSelector).remove()
      )

  @performRequest: ($form, callback, clickedLinkSelector)->
    $.ajax(
      url: $form.attr('action'),
      method: $form.attr('method'),
      data: $form.serializeArray()
      success: (data)=>
        callback.call @, data, clickedLinkSelector
      error: (response)=>
        $(@errorMessageContainer).text(response.responseText)
    )

  @displayUpdatedCardInfo: (updatedCardHtml, clickedLinkSelector)->
    $cardContainer = $(clickedLinkSelector).closest(@creditCardFormDivSelector)
    $cardContainer.next(@creditCardAreaSelector).remove()
    $cardContainer.replaceWith(updatedCardHtml)

  @displayNewlyAddedCard: (cardInfoHtml)->
    @toggleCardFormVisibility()
    @unMarkPrimaryCard()
    $firstCard = $(@creditCardAreaSelector + ':first')
    if $firstCard.length
      $(cardInfoHtml).insertBefore($firstCard)
    else
      $(cardInfoHtml).appendTo($(@cardsContainerSelector))
    @setDefaultInputValues()

  @styleDropdowns: ->
    $('.selectpicker').selectpicker { style: 'btn-selector-medium font15' }

  @unMarkPrimaryCard: ->
    $(@creditCardAreaSelector).removeClass(@primaryCreditCardAreaClassName)
    $(@creditCardAreaSelector).find(@setPrimaryCardLinkSelector).text(signupI18n.make_card_primary)

  @setDefaultInputValues: ->
    $form = $(@creditCardFormDivSelector)
    $form.find('input').val('')
    $form.find('select').prop('selectedIndex', 0).change()

  @toggleCardFormVisibility: (editLink)->
    $form = $(editLink).closest(@creditCardFormDivSelector)
    if $form.find('form').hasClass(@editCreditCardFormSelector)
      $form.next(@creditCardAreaSelector).show()
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
