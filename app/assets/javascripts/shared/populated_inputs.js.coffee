class @PopulatedInputs

  @container: 'body'

  @init: ->
    @bindAddLinkButton()
    @bindRemoveLinkButton()
    @populateExamplesInputs()

  @bindAddLinkButton: ->
    $(document).on 'click', '.lnk_container .plus_wrapper', (event)=>
      event.preventDefault()
      @addLink()

  @generateNewLink: ->
    $rows = $(@container).find('.lnk_container:first').first()
    $formclone = $rows.clone()
    $formclone.find('input').val ''
    $formclone

  @addLink: ->
    $newLink = @generateNewLink()
    if $(@container).find('.lnk_container:last').length
      $newLink.insertAfter($('.lnk_container:last'))
    else
      $(@container).append($newLink)
    @populateExamplesInputs()
    $newLink

  @bindRemoveLinkButton: ->
    $(document).on 'click', '.lnk_container .minus_wrapper', (event)=>
      event.preventDefault()
      $(event.target).parents('.lnk_container').remove()
      @refreshLinkButtons('removed')

  @populateExamplesInputs: ->
    if $(@container).find('.lnk_container .plus_wrapper').length > 1
      @refreshLinkButtons('added')
    else
      @refreshLinkButtons('removed')

  @refreshLinkButtons: (change)->
    $container = $(@container)
    if change is 'added'
      $container.find('.lnk_container .plus_wrapper').hide()
      $container.find('.lnk_container .examplelabel label').hide().first().show()
      $container.find('.lnk_container .minus_wrapper').show() if $container.find('.lnk_container .plus_wrapper').length > 1
      $container.find('.lnk_container .plus_wrapper:last').last().show()
    else if change is 'removed'
      $container.find('.lnk_container .minus_wrapper').hide() if $container.find('.lnk_container .plus_wrapper').length is 1
      $container.find('.lnk_container .plus_wrapper:last').last().show()
      $container.find('.lnk_container .examplelabel label').hide()
      $container.find('.lnk_container .examplelabel label').first().show()

class @InspirationLinksEditor extends PopulatedInputs
  @container: '.links-options'