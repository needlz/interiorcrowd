class ImageItemsList

  constructor: (@uploadOptions)->

  init: ->
    @bindUploadButton()
    @bindSaveButton()

  bindUploadButton: ->
    PicturesUploadButton.init @uploadOptions

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
  productList = new ImageItemsList(
    fileinputSelector: '.products-list #product_items',
    uploadButtonSelector: '.products-list .upload-button',
    thumbs:
      container: '.products-list .thumbs'
      selector: '#contest_request_product_items_image_ids'
      theme: ProductListThumbsTheme
    I18n: I18n
  )
  productList.init()
  similarStyles = new ImageItemsList(
    fileinputSelector: '.similar-styles #similar_styles',
    uploadButtonSelector: '.similar-styles .upload-button',
    thumbs:
      container: '.similar-styles .thumbs'
      selector: '#contest_request_similar_styles_image_ids'
      theme: ProductListThumbsTheme
    I18n: I18n
  )
  similarStyles.init()
