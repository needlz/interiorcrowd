class @SignUp

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
          @logFacebookPixelEvent(json.id)
          setTimeout(
            ->
              location.reload()
            200
          )
      error: (response)=>
        alert(response.responseText)

    ajaxRequestOptions = $.extend({}, defaultOptions, requestOptions)

    $.ajax(ajaxRequestOptions)

  @logFacebookPixelEvent: (clientId)->
    fbq('track', 'CompleteRegistration', { client_id: clientId })
