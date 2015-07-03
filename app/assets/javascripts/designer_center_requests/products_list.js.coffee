class ImageItemsEditor extends InlineEditor

  attributeIdentifierData: 'id'
  attributeSelector: '.dcProduct'
  sameEditCancelbutton: false
  editButtonSelector: '.dcEditProduct.edit'

  cancelButtonSelector: '.dcEditProduct.cancel'
  saveButtonSelector: '.dcEditProduct.save'
  deleteButtonSelector: '.dcProductTrash'

  bindEvents: ->
    super()
    @bindDeleteClick()

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

  append: (kind)->
    $.ajax(
      url: "/image_items/default"
      method: 'GET'
      data: { collaboration: true, kind: kind, contest_request_id: @contestRequestId() }
      success: (response)=>
        $newItem = $(response)
        $lastElement = $('.image-items .list-kind').filter("[data-kind='#{ kind }']").find('.dcAddProductItems').closest('.dcProduct')
        $newItem.insertBefore($lastElement)

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

  $('.dcAddProductItems').click (e)->
    e.preventDefault()
    $button = $(e.target).closest('[data-kind]')
    kind = $button.data('kind')
    itemsEditor.append(kind)

  ImageItemsView.init()
