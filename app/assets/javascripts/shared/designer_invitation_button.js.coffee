class @DesignerInvitationButton

  @I18n: ->
    I18n.invitations

  @buttonSelector: '.profile-card .invite-designer'

  @getDesignerId: ($button)->
    $button.parents('.profile-card').data('id')

  @bindInviteButtons: (contestId)->
    $(@buttonSelector).click (event)=>
      $button = $(event.target)
      designerId = @getDesignerId($button)
      @sendInviteRequest(designerId, $button, contestId)

  @beforeRequest: ($button)->
    $button.closest('button').find('b').text(@I18n().sending_invitation)

  @sendInviteRequest: (designerId, $button, contestId) ->
    @beforeRequest($button)
    data = { designer_id: designerId, contest_id: contestId }
    mixpanel.track('Designer invited', data)
    $.ajax(
      data: data
      url: '/designer_invitations'
      type: 'POST'
      success: (response)=>
        @onSuccess($button)
    )

  @onSuccess: ($button) ->
    $button.closest('button').find('b').text(@I18n().invited).removeClass(@buttonSelector)
