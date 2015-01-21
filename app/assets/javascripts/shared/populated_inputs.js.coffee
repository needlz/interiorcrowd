class @PopulatedInputs

  @init: ->
    @bindAddLinkButton()
    @bindRemoveLinkButton()
    @populateExamplesInputs()

  @bindAddLinkButton: ->
    $(document).on 'click', '.lnk_container .plus_wrapper', (event)=>
      event.preventDefault()
      @addLink()

  @addLink: ->
    $rows = $('.lnk_container:first').first()
    $formclone = $rows.clone()
    $formclone.find('input').val ''
    $formclone.insertAfter $('.lnk_container:last')
    @refreshLinkButtons('added')

  @bindRemoveLinkButton: ->
    $(document).on 'click', '.lnk_container .minus_wrapper', (event)=>
      event.preventDefault()
      $(event.target).parents('.lnk_container').remove()
      @refreshLinkButtons('removed')

  @populateExamplesInputs: ->
    @refreshLinkButtons('removed')

  @refreshLinkButtons: (change)->
    if change is 'added'
      $('.lnk_container .plus_wrapper').hide()
      $('.lnk_container .examplelabel label').hide().first().show()
      $('.lnk_container .minus_wrapper').show() if $('.lnk_container .plus_wrapper').length > 1
      $('.lnk_container .plus_wrapper:last').last().show()
    else if change is 'removed'
      $('.lnk_container .minus_wrapper').hide()  if $('.lnk_container .plus_wrapper').length is 1
      $('.lnk_container .plus_wrapper:last').last().show()
      $('.lnk_container .examplelabel label').hide()
      $('.lnk_container .examplelabel label').first().show()
