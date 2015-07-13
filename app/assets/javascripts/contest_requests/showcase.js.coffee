class @ConceptBoardShowcase

  @showcaseSelector: '#showcase'

  @init: ->
    $(@showcaseSelector).on 'click', '.remove', (event)=>
      event.preventDefault()
      requestId = $('.response[data-id]').data('id')
      detailId = $(event.target).closest('.lookbook-detail[data-id]').data('id')
      if requestId
        $.ajax(
          url: "/designer_center/responses/#{ requestId }/lookbook_details/#{ detailId }"
          method: 'DELETE'
          success: (response)=>
            CommentsBlock.fitCommentsArea()
            $('#showcase').replaceWith(response)
            ConceptBoardShowcase.init()
        )

    PicturesZoom.initGallery(enlargeButtonSelector: "#{ @showcaseSelector } .enlarge",
      galleryName: 'concept_board')

    $(@showcaseSelector).awShowcase
      content_width: 750
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
      dynamic_height: true
      speed_change: false
      viewline: false

$ ->
  ConceptBoardShowcase.init()