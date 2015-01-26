class @InlineEditor

  editButtonSelector: '.edit-button'
  cancelButtonSelector: '.cancel-button'
  attributeSelector: '.attribute'
  hiddenViewClass: 'hidden-view'

  bindEvents: ->
    @bindEditClick()

  bindEditClick: ->
    $(@attributeSelector).on 'click', @editButtonSelector, @, @onEditClick
    $(@attributeSelector).on 'click', @cancelButtonSelector, @, @onCancelClick

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
    $editButton.removeClass('edit-button').addClass('cancel-button')
    $optionsRow = @optionsRow($editButton)
    $preview = $optionsRow.find(@placeholderSelector).find('.view')
    $preview.hide()

    $formHtml = $(formHtml)
    $form = @editHolder($optionsRow, $formHtml)
    $form.show()

    @afterEditFormRetrieved?(attribute, formHtml)
    @editFormsCallbacks[attribute].apply(@, [$form, $preview]) if @editFormsCallbacks && @editFormsCallbacks[attribute]

  editHolder: ($optionsRow, $formHtml)->
    if $.contains(document.documentElement, $formHtml[0])
      $form = $formHtml
    else
      $form = $optionsRow.find('.edit')
      $form.html($formHtml)
    $form

  onCancelClick: (event)=>
    event.preventDefault()
    $editButton = $(event.target)
    editor = event.data
    attribute = editor.optionsRow($editButton).data(editor.attributeIdentifierData)
    editor.cancelEditing(attribute)

  cancelEditing: (attribute)->
    $optionsRow = $(@attributeSelector).filter("[data-#{ @attributeIdentifierData }=#{ attribute }]")
    $editButton = $optionsRow.find(@cancelButtonSelector)
    @updateEditButton($editButton)
    $view = $optionsRow.find('.view')
    $view.show()
    $form = $optionsRow.find('.edit')
    $form.hide()
    $editButton.removeClass('cancel-button').addClass('edit-button')
    @afterCancelEditing?($optionsRow)

  optionsRow: ($child)->
    $child.parents(@attributeSelector).filter("[data-#{ @attributeIdentifierData }]")

  updateEditButton: ($editButton)->
    $editButton.text(I18n.attribute_edit_button)

