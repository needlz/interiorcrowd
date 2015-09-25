class ImageItemsEditor extends InlineEditor

  attributeIdentifierData: 'id'
  attributeSelector: '.dcProduct'
  sameEditCancelbutton: false
  editButtonSelector: '.dcEditProduct.edit'

  cancelButtonSelector: '.dcEditProduct.cancel'
  saveButtonSelector: '.dcEditProduct.save'
  deleteButtonSelector: '.dcProductTrash'

  productItemSelector: '.row.dcProduct.item'
  itemHeadSelector: '.dcProductHead'
  itemTextSelector: '.col-sm-8'
  headStyleVariants: 'greenHead redHead'

  bindEvents: ->
    super()
    @bindDeleteClick()
    @subscribeToUpdates()
    @bindPriceValidation()
    @bindAutoSaving()

  bindDeleteClick: ->
    $(document).on 'click', "#{@attributeSelector} #{@deleteButtonSelector}", @, (event)=>
      event.preventDefault()
      imageItemId = @optionsRow($(event.target)).data('id')
      $.ajax(
        url: "/image_items/#{ imageItemId }"
        method: 'DELETE'
        success: (response)=>
          if response.destroyed
            @attributeElement(imageItemId).remove()
      )

  subscribeToUpdates: ->
    $ =>
      subscriptionChannel.subscribe subscriptionChannelName, (message) =>
        @displayProductItemFeedback(message.data)

  bindAutoSaving: ->
    $(document).on 'change', '.edit input, textarea', (event)=>
      $form = $(event.target).closest('form')
      imageItemId = @optionsRow($(event.target)).data('id')
      $(event.target).parents('.edit').find('.autosaving').show()
      $.ajax(
        url: "/image_items/#{ imageItemId }"
        method: 'POST'
        data: $form.serializeArray()
        success: =>
          $(event.target).parents('.edit').find('.autosaving').hide()
      )

  bindPriceValidation: ->
    $(document).on 'change', '#productPrice', (event)->
      rawPrice = $(event.target).val()
      trimmedPrice = $.trim(rawPrice)
      if /^\d+$/.test($.trim(trimmedPrice))
        $(event.target).val('$' + trimmedPrice)
      else
        $(event.target).val(trimmedPrice)

  displayProductItemFeedback: (rawMessage)->
    feedbackParams = JSON.parse(rawMessage)
    $productHead = @findProductItemHead(feedbackParams.id)

    @changeProductItemHeadStyle($productHead, feedbackParams.css_class)

    @setProductItemHeadText($productHead, feedbackParams.text)

  findProductItemHead: (id)->
    $("[data-id=" + id + "]" + @productItemSelector).find(@itemHeadSelector)

  changeProductItemHeadStyle: ($element, css_class)->
    $element.removeClass(@headStyleVariants)
    $element.addClass(css_class)

  setProductItemHeadText: ($element, text)->
    $element.find(@itemTextSelector).text(text)

  getForm: (id, $button)->
    @requestEditForm(id)

  requestEditForm: (imageItemId)->
    $.ajax(
      url: "/image_items/#{ imageItemId }/edit/"
      method: 'GET'
      success: (response)=>
        @onEditFormRetrieved(imageItemId, response)
    )

  afterEditFormRetrieved: (imageItemId, $form)->
    ImageItemsView.init()

    $thumb = $form.find('.dcProductImage')

    PicturesUploadButton.init
      fileinputSelector: $thumb.find('input[type="file"]')
      uploadButtonSelector: $thumb.find('img')
      thumbs:
        container: $thumb
        selector: $thumb.find('#image_item_image_id')
        theme: DefaultThumbsTheme
      I18n: I18n
      single: true

    $form.find(@cancelButtonSelector).one 'click', (e)=>
      e.preventDefault()
      @cancelEditing(imageItemId)

    $form.find(@saveButtonSelector).one 'click', (e)=>
      e.preventDefault()
      $form = $(e.target).closest('form')
      $form.on 'ajax:success', (event, data)=>
        @cancelEditing(imageItemId)
        @updateView($form, data)
      $form.trigger('submit.rails')

  updateView: ($child, data)->
    $view = @optionsRow($child).find('div.view')
    $view.html(data)

    ImageItemsView.init()

  save: (imageItemId)->
    $.ajax(
      url: "/image_items/#{ imageItemId }"
      method: 'PATCH'
      data: {}
      success: (response)=>
        @cancelEditing(imageItemId)
    )

  append: (kind, imageId)->
    $.ajax(
      async: false,
      url: "/image_items/default"
      method: 'GET'
      data:
        collaboration: true
        kind: kind
        contest_request_id: @contestRequestId()
        image_id: imageId
      success: (response)=>
        $newItem = $(response)
        $lastElement = $('.image-items .list-kind').filter("[data-kind='#{ kind }']").find('.dcAddProductItems').closest('.dcProduct')
        $newItem.insertBefore($lastElement)
        @afterEditFormRetrieved($newItem.data('id'), $newItem.find('div.edit'))
        ImageItemsView.init()
    )

  contestRequestId: ->
    $('.response[data-id]').data('id')

class @ImageItemsView

  @init: ->
    $('.dcProductDesc').each (index, element)->
      $element = $(element)
      unless $element.data('enscroll')
        $element.enscroll({
          verticalTrackClass: 'scrollBoxCommentsTrack',
          verticalHandleClass: 'scrollBoxCommentsHandle',
          minScrollbarLength: 28
        });

$ ->
  itemsEditor = new ImageItemsEditor()
  itemsEditor.init()

  ImageItemsView.init()

  $('.dcAddProductItems').each (index, element)->
    $addButton = $(element)

    PicturesUploadButton.init
      fileinputSelector: $addButton.find('input[type="file"]')
      uploadButtonSelector: $addButton.find('a')
      thumbs:
        selector: $addButton.find('#image_item_image_id')
      I18n: I18n
      single: true
      uploading:
        onUploaded: (event)=>
          kind = $addButton.data('kind')
          imageId = $addButton.find('#image_item_image_id').val()
          itemsEditor.append(kind, imageId)
