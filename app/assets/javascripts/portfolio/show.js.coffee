class InvitationButton extends DesignerInvitationButton

  @buttonSelector: '.inviteToContest.active'

  @getDesignerId: ($button)->
    $button.parents('.designer-portfolio').data('id')

  @onSuccess: ($button) ->
    $button.text(@I18n().invited).off('click')

  @beforeRequest: ($button)->
    $button.text(@I18n().sending_invitation)

$ ->
  contestId = $(InvitationButton.buttonSelector).data('contest-id')
  InvitationButton.bindInviteButtons(contestId)
