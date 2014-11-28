class @ProfileEditor extends InlineEditor

  attributeIdentifierData: 'id'
  attributeSelector: '.attribute'
  editButtonSelector: '.edit-button'
  placeholderSelector: '.placeholder'
  numberFields: '#client_card_number, #client_card_ex_month, #client_card_ex_year, #client_card_cvc, #client_zip'

  bindEvents: ->
    @bindDoneButton()
    @initNumberFields()
    super()

  initNumberFields: ->
    $('.attribute').on('keypress', @numberFields, (e)->
      char = String.fromCharCode(e.which);
      !!char.match(/[0-9]/)
    )

  getForm: (attribute, onEditFormRetrieved)=>
    formHtml = $(".attribute[data-id='#{ attribute }'] .preview .edit").html()
    $(".attribute[data-id='#{ attribute }'] .preview .edit").empty()
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
    email: ($form, $view)->
      @updateText($form, $view, 'email')
    address: ($form, $view)->
      @updateText($form, $view, 'address')
      @updateText($form, $view, 'state')
      @updateText($form, $view, 'zip')
    billing_information: ($form, $view)->
      @updateText($form, $view, 'card_number')
      @updateText($form, $view, 'card_ex_month')
      @updateText($form, $view, 'card_ex_year')
      @updateText($form, $view, 'card_cvc')

  updateText: ($form, $view, field)->
    $view.find('.' + field).text($form.find('#client_' + field).val())
    $form.find('#client_' + field).attr('value', $form.find('#client_' + field).val())

$ ->
  profile = new ProfileEditor()
  profile.bindEvents()
