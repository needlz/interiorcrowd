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
    console.log  requestOptions
    defaultOptions =
      method: 'POST'
      dataType: 'json'
      success: (json)=>
        location.reload() if json.id
      error: (response)=>
        alert(response.responseText)

    ajaxRequestOptions = $.extend({}, defaultOptions, requestOptions)

    console.log ajaxRequestOptions
    $.ajax(ajaxRequestOptions)