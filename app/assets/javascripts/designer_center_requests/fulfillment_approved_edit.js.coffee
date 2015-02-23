class ProductItemsEditor extends InlineEditor

  attributeIdentifierData: 'id'
  attributeSelector: '.product-item'

  getForm: (id)->
    productItemId = id
    $container = $(@attributeSelector).filter("[data-id='#{ productItemId }']")
    $editForm = $container.find('.edit-form')
    $editForm.removeClass('hidden')
    $view = $container.find('.view')
    $view.hide()
    @onEditFormRetrieved(productItemId, $editForm.html())

  afterCancelEditing: ($optionsRow)->
    $optionsRow.find('.edit-form').addClass('hidden')
    $optionsRow.find('.view').show()

  bindEvents: ->
    super()
    @bindSaveClick()
    ProductItemImageUploader.init(@imageIdInput)

  bindSaveClick: ->
    $(@attributeSelector).on 'click', '.save-button', (e)=>
      e.preventDefault()
      $saveButton = $(e.target)
      $container = $saveButton.parents(@attributeSelector)
      @update($container)
      @cancelEditing($container.data('id'))

  onCancelClick: (event)=>
    super(event)
    $cancelButton = $(event.target)
    $container = $cancelButton.parents(@attributeSelector)
    @undo($container)

  update: ($container)->
    @updateImage($container)
    @updateTextFields($container)

  undo: ($container)->
    @updateImage($container, true)
    @updateTextFields($container, true)

  updateImage: ($container, undo)->
    $viewImage = $container.find('.view img')
    $editImage = $container.find('.edit-form img')
    $editImageId = $container.find('.edit-form').find(@imageIdInput)
    $viewImageId = $container.find('.view').find(@imageIdInput)
    if undo
      $editImage.attr('src', $viewImage.attr('src'))
      $editImageId.val($viewImageId.val())
    else
      $viewImage.attr('src', $editImage.attr('src'))
      $viewImageId.val($editImageId.val())

  updateTextFields: ($container, undo)->
    for attributeSelector in ['.name', '.brand', '.price']
      $input = $container.find('.edit-form').find(attributeSelector)
      $caption = $container.find('.view').find(attributeSelector)
      @updatePlainTextField($input, $caption, undo)
    @updateLinkField($container.find('.edit-form .link'), $container.find('.view .link'), undo)

  updatePlainTextField: ($input, $caption, undo)->
    if undo
      $input.val($caption.text())
    else
      $caption.text($input.val())

  updateLinkField: ($input, $caption, undo)->
    @updatePlainTextField($input, $caption, undo)
    if undo
      $input.val($caption.attr('href'))
    else
      $caption.attr('href', $input.val())

class ProductItemImageUploader

  @init: (imageIdInput)->
    $('.product-list .product-item').each (index, element)=>
      PicturesUploadButton.init
        fileinputSelector: $(element).find('input[type="file"]')
        uploadButtonSelector: $(element).find('.btn-change-image')
        thumbs:
          container: $(element).find('.edit-form')
          selector: $(element).find('.edit-form').find(imageIdInput)
          theme: DefaultThumbsTheme
        I18n: I18n
        single: true

class @FulfillmentApprovedEdit

  imageIdInput: 'input[name="contest_request[product_items][image_ids][]"]'

  @init: ->
    @bindFooterButtons()
    productItemsEditor = new ProductItemsEditor()
    productItemsEditor.imageIdInput = @imageIdInput
    productItemsEditor.bindEvents()

  @form: ->
    $('.edit_contest_request')

  @bindFooterButtons: ->
    $form = @form()

    $('.footer .save-button').click (e)->
      e.preventDefault()
      $form.find('.edit-form').find(@imageIdInput).remove()
      $form.submit()

    $('.footer .submit-button').click (e)->
      e.preventDefault()
      $form.find('.edit-form').find(@imageIdInput).remove()
      $status_input = $('<input type="hidden">').attr('name', 'contest_request[status]').val('finished')
      $status_input.appendTo($form)
      $form.submit()

$ ->
  FulfillmentApprovedEdit.init()
