class @InlineEditor

  editButtonClassName: 'edit-button'
  cancelButtonClassName: 'cancel-button'
  editButtonSelector: '.edit-button'
  cancelButtonSelector: '.cancel-button'
  attributeSelector: '.attribute'
  hiddenViewClass: 'hidden-view'
  sameEditCancelbutton: true

  bindEvents: ->
    @bindEditClick()

  bindEditClick: ->
    $(document).on 'click', "#{@attributeSelector} #{@editButtonSelector}", @, @onEditClick
    $(document).on 'click', "#{@attributeSelector} #{@cancelButtonSelector}", @, @onCancelClick

  editAll: ->
    $("#{@attributeSelector} #{@editButtonSelector}").click()

  onEditClick: (event)->
    event.preventDefault()
    $button = $(event.target)
    editor = event.data
    attribute = $button.parents(editor.attributeSelector).data(editor.attributeIdentifierData)
    editor.requestAttributeForm(attribute, $button)

  formPlaceholder: ($childElement)->
    @optionsRow($childElement).find(@placeholderSelector)

  requestAttributeForm: (attribute, $button)->
    @getForm(attribute, $button)

  onEditFormRetrieved: (attribute, formHtml)=>
    $editButton = $(@attributeSelector).filter("[data-#{ @attributeIdentifierData }=#{ attribute }]").find(@editButtonSelector)
    if @sameEditCancelbutton
      $editButton.text(I18n.attribute_cancel_button)
      $editButton.removeClass(@editButtonClassName).addClass(@cancelButtonClassName)
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
    $cancelButton = $(event.target)
    editor = event.data
    attribute = editor.optionsRow($cancelButton).data(editor.attributeIdentifierData)
    editor.cancelEditing(attribute, $cancelButton)

  cancelEditing: (attribute, $cancelButton)->
    $optionsRow = if $cancelButton then $cancelButton.closest(@attributeSelector) else $(@attributeSelector).filter("[data-#{ @attributeIdentifierData }=#{ attribute }]")
    $editButton = $optionsRow.find(@cancelButtonSelector)
    if @sameEditCancelbutton
      @updateEditButton($editButton)
      $editButton.removeClass(@cancelButtonClassName).addClass(@editButtonClassName)
    $view = $optionsRow.find('.view')
    $view.show()
    $form = $optionsRow.find('.edit')
    $form.hide()
    @afterCancelEditing?($optionsRow)

  optionsRow: ($child)->
    $child.parents(@attributeSelector).filter("[data-#{ @attributeIdentifierData }]")

  updateEditButton: ($editButton)->
    $editButton.text(I18n.attribute_edit_button)
