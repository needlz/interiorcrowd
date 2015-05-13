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
    $('form.client-profile-form').on 'ajax:success', (e, data)=>
      $form = $(e.target)
      $preview = $form.parents('.edit-profile.attribute').find('.view')
      $preview.html(data)
      mixpanel.track('Client profile edited', { client_id: $form.data('client-id') })

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
      editor.cancelEditing(attribute)
    )

  editFormsCallbacks:
    billing_information: ($form, $view)->
      @initSelectPicker()
    phone_number: ($form, $view)->
      $form.find('#client_phone_number').phoneNumber()


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
