class @InlineEditor

  editButtonSelector: '.edit-button'
  attributeSelector: '.attribute'
  hiddenViewClass: 'hidden-view'

  bindEvents: ->
    @bindEditClick()

  bindEditClick: ->
    $(@attributeSelector).find(@editButtonSelector).click(@, @onEditClick)

  onEditClick: (event)->
    event.preventDefault()
    $button = $(event.target)
    editor = event.data
    attribute = $button.parents(editor.attributeSelector).data(editor.attributeIdentifierData)
    editor.requestAttributeForm(attribute)

  formPlaceholder: ($childElement)->
    @optionsRow($childElement).find(@placeholderSelector)

  requestAttributeForm: (attribute)->
    @getForm(attribute)

  onEditFormRetrieved: (attribute, formHtml)=>
    $editButton = $(@attributeSelector).filter("[data-#{ @attributeIdentifierData }=#{ attribute }]").find(@editButtonSelector)
    $editButton.text(I18n.attribute_cancel_button)
    $editButton.off('click').click(@, @onCancelClick)
    $optionsRow = @optionsRow($editButton)
    $preview = $optionsRow.find(@placeholderSelector).find('.view')
    $preview.hide()
    $form = $optionsRow.find(@placeholderSelector).find('.edit')
    $form.html(formHtml).show()
    @afterEditFormRetrieved?(attribute, formHtml)
    @editFormsCallbacks[attribute]?() if @editFormsCallbacks

  onCancelClick: (event)=>
    event.preventDefault()
    $editButton = $(event.target)
    editor = event.data
    attribute = editor.optionsRow($editButton).data(editor.attributeIdentifierData)
    editor.cancelEditing(attribute)

  cancelEditing: (attribute)->
    $optionsRow = $(@attributeSelector).filter("[data-#{ @attributeIdentifierData }=#{ attribute }]")
    $editButton = $optionsRow.find(@editButtonSelector)
    @updateEditButton($editButton)
    $view = $optionsRow.find('.view')
    $view.show()
    $form = $optionsRow.find('.edit')
    $form.hide()
    $editButton.off('click').click(@, @onEditClick)
    @afterCancelEditing?($optionsRow)

  optionsRow: ($child)->
    $child.parents(@attributeSelector).filter("[data-#{ @attributeIdentifierData }]")

  updateEditButton: ($editButton)->
    $editButton.text(I18n.attribute_edit_button)

