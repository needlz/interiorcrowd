class ProductItemsEditor extends InlineEditor

  attributeIdentifierData: 'id'
  attributeSelector: '.product-item'
  sameEditCancelbutton: false

  getForm: (id, $button)->
    productItemId = id
    $container = $button.closest(@attributeSelector)
    $editForm = $container.find('.edit-form')
    $editForm.removeClass('hidden')
    $container.find('.view').hide()
    @onEditFormRetrieved(productItemId, $editForm.html())

  afterCancelEditing: ($optionsRow)->
    $optionsRow.find('.edit-form').addClass('hidden')
    $optionsRow.find('.view').show()

  bindEvents: ->
    super()
    @bindSaveClick()
    ProductItemImageUploader.init(@imageIdInput)

  bindSaveClick: ->
    $(document).on 'click', "#{@attributeSelector} .save-button", (e)=>
      e.preventDefault()
      $saveButton = $(e.target)
      $container = $saveButton.parents(@attributeSelector)
      @update($container)
      @cancelEditing($container.data('id'), $saveButton)

  onCancelClick: (event)=>
    super(event)
    $cancelButton = $(event.target)
    $container = $cancelButton.parents(@attributeSelector)
    @undo($container)

  update: ($container)->
    @updateImage($container)
    @updateTextFields($container)

  undo: ($containers)->
    $containers.each (index, container)=>
      $container = $(container)
      @updateImage($container, true)
      @updateTextFields($container, true)

  updateImage: ($container, undo)->
    $viewImage = $container.find('.view img')
    $editFormImage = $container.find('.edit-form img')
    $editFormImageIdInput = $container.find('.edit-form').find(@imageIdInput)
    $viewImageIdInput = $container.find('.view').find(@imageIdInput)
    if undo
      $editFormImage.attr('src', $viewImage.attr('src'))
      $editFormImageIdInput.val($viewImageIdInput.val())
    else
      $viewImage.attr('src', $editFormImage.attr('src'))
      $viewImageIdInput.val($editFormImageIdInput.val())

  updateTextFields: ($container, undo)->
    for attributeSelector in ['.name', '.brand', '.dimensions', '.price']
      $input = $container.find('.edit-form').find(attributeSelector)
      $caption = $container.find('.view').find(attributeSelector)
      @updatePlainTextField($input, $caption, undo)
    @updateLinkField($container.find('.edit-form .link'), $container.find('.view .link'), undo)

  updatePlainTextField: ($input, $caption, undo)->
    if undo
      $input.val($.trim($caption.text()))
    else
      $caption.text($input.val())

  updateLinkField: ($input, $caption, undo)->
    @updatePlainTextField($input, $caption, undo)
    if undo
      $input.val($.trim($caption.text()))
    else
      $caption.attr('href', @link($input.val()))

  link: (href)->
    if href.match /^https?\:/
      href
    else
      "http://#{ href }"

class ProductItemImageUploader

  @init: (imageIdInput)->
    @imageIdInput = imageIdInput
    $('.product-list .product-item').each (index, element)=>
      @initItem(element)

  @initItem: (element)->
    PicturesUploadButton.init
      fileinputSelector: $(element).find('input[type="file"]')
      uploadButtonSelector: $(element).find('.btn-change-image')
      thumbs:
        container: $(element).find('.edit-form')
        selector: $(element).find('.edit-form').find(@imageIdInput)
        theme: DefaultThumbsTheme
      I18n: I18n
      single: true

class @FulfillmentApprovedEdit

  @imageIdInput: 'input[name*="[image_ids][]"]'

  @init: ->
    @bindFooterButtons()
    @bindAddProductButton()
    @bindPriceInputs()
    @productItemsEditor = new ProductItemsEditor()
    @productItemsEditor.imageIdInput = @imageIdInput
    @productItemsEditor.bindEvents()

  @bindPriceInputs: ->
    $('.edit-form .price').currencyInput()

  @form: ->
    $('.edit_contest_request')

  @bindFooterButtons: ->
    $form = @form()

    $('.footer .save-button').click (e)=>
      e.preventDefault()
      @clearEditFormInputs($form)
      $form.submit()

    $('.footer .submit-button').click (e)=>
      e.preventDefault()
      @clearEditFormInputs($form)
      $status_input = $('<input type="hidden">').attr('name', 'contest_request[status]').val('finished')
      $status_input.appendTo($form)
      $form.submit()

  @bindAddProductButton: ->
    $('.add-product-button').click =>
      mixpanel.track('Product item added to final design')
      @addProductItem()

  @addProductItem: ->
    $.ajax(
      url: '/image_items/new'
      success: (formHtml)=>
        @appendProductItemForm(formHtml)
        @bindPriceInputs()
    )

  @appendProductItemForm: (formHtml)=>
    $elem = $(formHtml)
    $('.product-list').append($elem)
    ProductItemImageUploader.initItem($elem)
    $elem.find("#{ @productItemsEditor.editButtonSelector }").click()

  @clearEditFormInputs: ($form)->
    $form.find('.edit-form').find(@imageIdInput).remove()

  @editAll: ->
    @productItemsEditor.editAll()

$ ->
  FulfillmentApprovedEdit.init()
  FulfillmentApprovedEdit.editAll()
