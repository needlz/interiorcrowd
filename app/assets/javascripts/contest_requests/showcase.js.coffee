class @ConceptBoardShowcase

  @showcaseSelector: '#showcase'
  @showcaseThumbsSelector: '#showcase .showcase-thumbnail-wrapper .showcase-thumbnail'

  @init: (slideIndex = null)->
    PicturesZoom.initGallery(enlargeButtonSelector: "#{ @showcaseSelector } .enlarge",
      galleryName: 'concept_board')

    unless $(@showcaseSelector).data('single')
      @generateShowcase(slideIndex)

    @bindRemoveButtons()

  @removeConceptBoard: (requestId, detailId)=>
    $.ajax(
      url: "/designer_center/responses/#{ requestId }/lookbook_details/#{ detailId }"
      method: 'DELETE'
      success: (response)=>
        CommentsBlock.fitCommentsArea()
        $('#showcase').replaceWith(response)
        ConceptBoardShowcase.init()
    )

  @removeTemporaryConceptBoard: =>
    $imageIds = $(@showcaseSelector).closest('.concept-board').find('#concept_board_picture_id')
    imageIds = $imageIds.val()
    $.ajax(
      url: "/lookbook_details/remove_preview"
      data: { image_ids: imageIds }
      method: 'DELETE'
      success: (response)=>
        CommentsBlock.fitCommentsArea()
        $('#showcase').replaceWith(response)
        ConceptBoardShowcase.init()
        $imageIds.val('')
    )

  @generateShowcase: (slideIndex)=>
    $(@showcaseSelector).awShowcase
      content_width: 750
      content_height: 664
      fit_to_parent: false
      auto: false
      interval: 3000
      continuous: false
      loading: true
      tooltip_width: 200
      tooltip_icon_width: 32
      tooltip_icon_height: 32
      tooltip_offsetx: 18
      tooltip_offsety: 0
      arrows: true
      buttons: true
      btn_numbers: true
      keybord_keys: true
      mousetrace: false
      pauseonover: true
      stoponclick: true
      transition: 'hslide'
      transition_delay: 300
      transition_speed: 500
      show_caption: 'onhover'
      thumbnails: true
      thumbnails_position: 'outside-last'
      thumbnails_direction: 'horizontal'
      thumbnails_slidex: 0
      dynamic_height: false
      speed_change: false
      viewline: false

    $(@showcaseThumbsSelector).eq(slideIndex).click()

  @bindRemoveButtons: =>
    $(@showcaseSelector).on 'click', '.remove', (event)=>
      $.confirm(
        text: 'Are you sure you want to delete that concept board?'
        confirm: =>
          @removeCurrentConceptBoard($(event.target))
        confirmButton: 'Yes I am'
        cancelButton: 'No'
        confirmButtonClass: 'btn-danger'
        cancelButtonClass: 'btn-default'
        dialogClass: 'modal-dialog modal-sm'
      )

  @removeCurrentConceptBoard: ($removeButton)=>
    requestId = $('.response[data-id]').data('id')
    detailId = $removeButton.closest('.lookbook-detail[data-id]').data('id')
    if requestId
      @removeConceptBoard(requestId, detailId)
    else
      @removeTemporaryConceptBoard()

$ ->
  ConceptBoardShowcase.init()
