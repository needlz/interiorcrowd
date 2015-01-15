class Lookbook
  @init: ->
    @bindContinueButton()
    @setupImageUploader()

  @bindContinueButton: ->
    $(".continue").click (e) =>
      e.preventDefault()
      $(".text-error").text('')
      @validateAndSubmit()

  @setupImageUploader: ->
    $("#file_input").initUploader
      done: (event, data)=>
        for file in data.result.files
          @addThumb(file)

  @validateAndSubmit: ->
    $("#lookbook").submit()

  @addThumb: (file)->
    url = file.url
    image_id = file.id
    $("#image_display").append """
              <div class='col-sm-8 lookbook-thumb'>
                <div class='img'>
                  <img src='#{ url }' />
                </div>
                <input name='lookbook[picture][urls][]' type='hidden' value='#{ url }'>
                <input name='lookbook[picture][ids][]' type='hidden' value='#{ image_id }'>
              </div>
    """

$ ->
  Lookbook.init()
