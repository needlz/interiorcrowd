class InvitationButton extends DesignerInvitationButton

  @buttonSelector: '.inviteToContest.active'

  @getDesignerId: ($button)->
    $button.parents('.designer-portfolio').data('id')

  @onSuccess: ($button) ->
    $button.text(@I18n().invited).off('click')

  @beforeRequest: ($button)->
    $button.text(@I18n().sending_invitation)

class @Portfolio

  @init: ->
    contestId = $(InvitationButton.buttonSelector).data('contest-id')
    InvitationButton.bindInviteButtons(contestId)

    @initAboutEllipsis()
    $(window).resize =>
      @initAboutEllipsis()
    $('.user_portfolio_profile .about .readmore').click (e)=>
      e.preventDefault()
      $('.user_portfolio_profile .about .text').dotdotdot()
      $('.user_portfolio_profile .about .readmore').hide()

  @initAboutEllipsis: (height)->
    $('.user_portfolio_profile .about .text').dotdotdot({ height: 100 })

$ ->
  Portfolio.init()
