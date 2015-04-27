class ImageItemsList

  constructor: (@uploadOptions)->

  init: ->
    @bindUploadButton()
    @bindSaveButton()

  bindUploadButton: ->
    PicturesUploadButton.init @uploadOptions

  bindSaveButton: ->
    $('.save-fulfillment').off('click').click (e)=>
      e.preventDefault()
      $form = $('.edit_contest_request')
      @removeTemplateInputs($form)
      mixpanel.track('Product list updated',
        { data: $form.serializeArray(), contest_request_id: $('.response').data('id') }
      )
      setTimeout ->
        $form.submit()
      , 300

  removeTemplateInputs: ($form)->
    $form.find('.template').empty()

class ProductListThumbsTheme extends RemovableThumbsTheme

  init: ->
    @$container.on 'click', '.small_close', @removeThumb

  createThumb: (imageUrl, imageId)->
    @removeDefaultItems()

    $template = @$container.find('.template')
    $container = $template.clone()
    $container.removeClass('template').addClass('thumb')
    $container.find('img.main-image').attr('src', imageUrl).data('id', imageId)
    $container.find('.image-id').val(imageId)
    $container

  getImageId: ($thumb)->
    $thumb.find('.main-image').data('id')

  removeDefaultItems: ->
    @remove(@$container.find('.thumb.default'))

$ ->
  productList = new ImageItemsList(
    fileinputSelector: '.products-list #product_items',
    uploadButtonSelector: '.products-list .upload-button',
    thumbs:
      container: '.products-list .thumbs'
      theme: ProductListThumbsTheme
    I18n: I18n
    uploading:
      onUploaded: (event)->
        mixpanel.track 'Product item uploaded'
  )
  productList.init()
  similarStyles = new ImageItemsList(
    fileinputSelector: '.similar-styles #similar_styles',
    uploadButtonSelector: '.similar-styles .upload-button',
    thumbs:
      container: '.similar-styles .thumbs'
      theme: ProductListThumbsTheme
    I18n: I18n
    uploading:
      onUploaded: (event)->
        mixpanel.track 'Similar style uploaded'
  )
  similarStyles.init()
