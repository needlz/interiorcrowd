class @ProfileEditor extends InlineEditor

  attributeIdentifierData: 'id'
  placeholderSelector: '.placeholder'
  numberFields: '#client_card_number, #client_card_ex_month, #client_card_ex_year, #client_card_cvc, #client_zip'
  pencilImg: '<img src="/assets/pencil.png"/>'

  bindEvents: ->
    super()
    @bindDoneButton()
    @initNumberFields()

  initNumberFields: ->
    $('.attribute').on('keypress', @numberFields, digitsFilter)

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
    username: ($form, $view)->
      @updateText($form, $view, 'email')
    address: ($form, $view)->
      @updateText($form, $view, field) for field in ['address', 'state', 'zip']
    billing_information: ($form, $view)->
      @updateText($form, $view, field) for field in ['card_number', 'card_ex_month', 'card_ex_year', 'card_cvc']

  updateText: ($form, $view, field)->
    $input = $form.find("#client_#{ field }")
    $view.find(".#{ field }").text($input.val())
    $input.attr('value', $input.val())

  updateEditButton: ($elem)->
    $elem.html(@pencilImg)



$ ->
  profile = new ProfileEditor()
  profile.bindEvents()
