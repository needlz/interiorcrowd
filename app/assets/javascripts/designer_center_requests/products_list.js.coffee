class ProductsList

  constructor: (@thumbsSelector, @uploadButtonSelector)->

  init: ->
    @bindUploadButton()
    @bindSaveButton()

  bindUploadButton: ->
    $button = $(@uploadButtonSelector)
    PicturesUploadButton.init
      fileinputSelector: '.products-list #product_items',
      uploadButtonSelector: @uploadButtonSelector,
      thumbs:
        container: @thumbsSelector
        selector: '#contest_request_product_items_image_ids'
        theme: ProductListThumbsTheme
      I18n: I18n

  bindSaveButton: ->
    $('.save-fulfillment').click (e)=>
      e.preventDefault()
      $form = $('.edit_contest_request')
      @removeTemplateInputs($form)
      $form.submit()

  removeTemplateInputs: ($form)->
    $form.find('.template').empty()

class ProductListThumbsTheme extends RemovableThumbsTheme

  init: ->
    @$container.on 'click', '.small_close', @removeThumb

  createThumb: (imageUrl, imageId)->
    $template = @$container.find('.template')
    $container = $template.clone()
    $container.removeClass('template').addClass('thumb')
    $container.data('id', imageId)
    $container.find('img.main-image').attr('src', imageUrl)
    $container

$ ->
  productList = new ProductsList('.products-list .thumbs', '.products-list .upload-button')
  productList.init()
