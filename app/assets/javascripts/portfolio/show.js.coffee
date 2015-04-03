class InvitationButton extends DesignerInvitationButton

  @buttonSelector: '.inviteToContest.active'

  @getDesignerId: ($button)->
    $button.parents('.designer-portfolio').data('id')

  @onSuccess: ($button) ->
    $button.text(@I18n().invited).off('click')

  @beforeRequest: ($button)->
    $button.text(@I18n().sending_invitation)

class @Portfolio

  @aboutExpandButtonSelector: '.user_portfolio_profile .about .readmore'
  @aboutTextSelector: '.user_portfolio_profile .about .text'

  @init: ->
    contestId = $(InvitationButton.buttonSelector).data('contest-id')
    InvitationButton.bindInviteButtons(contestId)

    @initAboutEllipsis()
    $(window).resize =>
      @initAboutEllipsis()

    $(@aboutExpandButtonSelector).click (e)=>
      e.preventDefault()
      @expandAboutBlock()
      $(@aboutExpandButtonSelector).hide()

  @initAboutEllipsis: ->
    $(@aboutTextSelector).dotdotdot({ height: 100 })

  @expandAboutBlock: ->
    $(@aboutTextSelector).dotdotdot()

$ ->
  Portfolio.init()
