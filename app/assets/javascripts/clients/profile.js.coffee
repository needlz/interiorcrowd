class @ProfileEditor extends InlineEditor

  attributeIdentifierData: 'id'
  placeholderSelector: '.placeholder'
  numberFields: '#client_card_number, #client_card_ex_month, #client_card_ex_year, #client_card_cvc, #client_zip, #client_billing_zip'
  cardNumber: 'card_number'
  fourDigitsDelta: -4

  bindEvents: ->
    super()
    @bindDoneButton()
    @initNumberFields()

  initNumberFields: ->
    $(@numberFields).ForceNumericOnly();

  getForm: (attribute, onEditFormRetrieved)=>
    formHtml = $(".attribute[data-id='#{ attribute }'] .preview .edit")
    @onEditFormRetrieved(attribute, formHtml)

  bindDoneButton: ->
    $('body').on('click', '.edit .done', @, (event)->
      editor = event.data
      $attributeRow = $(event.target).parents(editor.attributeSelector)
      attribute = $attributeRow.data(editor.attributeIdentifierData)
      $form = $attributeRow.find('.edit')
      $view = $attributeRow.find('.view')
      editor.previewCallbacks[attribute].apply(editor, [$form, $view]) if editor.previewCallbacks[attribute]?
      editor.cancelEditing(attribute)
    )

  previewCallbacks:
    first_name: ($form, $view)->
      @updateText($form, $view, 'first_name')
    last_name: ($form, $view)->
      @updateText($form, $view, 'last_name')
    username: ($form, $view)->
      @updateText($form, $view, 'email')
    phone_number: ($form, $view)->
      @updateText($form, $view, 'phone_number')
    address: ($form, $view)->
      @updateText($form, $view, field) for field in ['address', 'state', 'zip', 'city']
    billing_address: ($form, $view)->
      @updateText($form, $view, field) for field in ['billing_address', 'billing_state', 'billing_zip', 'billing_city']
    billing_information: ($form, $view)->
      @updateText($form, $view, field) for field in ['card_ex_month', 'card_ex_year', 'card_cvc']
      @updateCardNumber($form, $view, @cardNumber)

  editFormsCallbacks:
    billing_information: ($form, $view)->
      @initSelectPicker()

  updateText: ($form, $view, field)->
    @updateSection($form, $view, field, ($input)->
      $input.val()
    )

  updateCardNumber: ($form, $view, field)->
    @updateSection($form, $view, field, ($input)=>
      $input.val().slice(@fourDigitsDelta)
    )

  updateSection: ($form, $view, field, callback)->
    $input = $form.find("#client_#{ field }")
    value = callback($input)
    $view.find(".#{ field }").text(value)
    $input.attr('value', $input.val())

  updateEditButton: ($elem)->
    $editButton = $('.edit-button.template').html()
    $elem.html($editButton)

  initSelectPicker: ->
    $('.expiration-picker').selectpicker({
      style: 'btn-selector-medium font15'
    });

$ ->
  profile = new ProfileEditor()
  profile.bindEvents()
