class @InspirationLinksEditor

  init: ->
    @bindAddLinkButtons()
    @bindRemoveLinkButtons()
    if @links().find('.link').length
      @refreshLinks()
    else
      @addLink()

  bindAddLinkButtons: ->
    $('.links').on 'click', '.link .add-button', (event)=>
      event.preventDefault()
      @addLink()

  bindRemoveLinkButtons: ->
    $('.links').on 'click', '.link .remove-button', (event)=>
      event.preventDefault()
      @removeLink($(event.target).closest('.link'))

  linkTemplate: ->
    $('.link-template .link')

  links: ->
    $('.links')

  addLink: ->
    $newLink = @linkTemplate().clone()
    $input = $newLink.find('input')
    $input.attr('name', $input.data('name'))
    $newLink.appendTo(@links())

    @refreshLinks()

  removeLink: ($input)->
    $input.remove()

  refreshLinks: ->
    linksToAddMinusButton = @links().find('.link:not(:last-child)')
    linksToAddMinusButton.find('.add-button').hide()
    linksToAddMinusButton.find('.remove-button').show()

    lastLink = @links().find('.link:last-child')
    lastLink.find('.add-button').show()
