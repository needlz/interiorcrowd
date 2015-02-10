class @ConceptboardComment

  @init: =>
    console.log('qqq')
    $('.comment-create').on 'click': =>
      @.create()

  @create: (path) ->
    text = $('.commentTextArea textarea').val()
    request = $('.commentTextArea textarea').attr('request')
    console.log(text)
    console.log( request )
    $.ajax(
      data: {  comment: {text: text, contest_request_id: request}  }
      url: "/contest_requests/#{request}/add_comment"
      type: 'POST'
      success: (data)=>
        console.log('sssssssss')
      error: ->
        console.log('aaaaaa')
    )
