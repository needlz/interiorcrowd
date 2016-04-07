class @SignUp

  @alertSelector: '#signUpModal .alert-warning'

  @facebookLogin: ->
    FB.login(
      (response) =>
        token = response.authResponse.accessToken
        @signUpWithToken(token)
      { scope: 'email' }
    )

  @quick: ->
    @signUpWithEmail($('#email-sign-up :input').serializeArray())

  @signUpWithToken: (token)->
    @signUpRequest
      data: { token: token }
      url: '/clients/sign_up_with_facebook'

  @signUpWithEmail: (params)->
    @signUpRequest
      data: params
      url: '/clients/sign_up_with_email'

  @signUpRequest: (requestOptions) ->
    defaultOptions =
      method: 'POST'
      dataType: 'json'
      success: (json)=>
        if json.id
          fbq('track', 'CompleteRegistration')
          setTimeout(
            =>
              location.reload()
            200
          )
      error: (response)=>
        @showAlert(response.responseJSON.error)

    ajaxRequestOptions = $.extend({}, defaultOptions, requestOptions)

    $.ajax(ajaxRequestOptions)

  @showAlert: (html) ->
    $alert = $(@alertSelector)
    $alert.show()
    $alert.on('click', '.close', ->
      $alert.hide()
    )
    $alert.find('.text').html(html)
