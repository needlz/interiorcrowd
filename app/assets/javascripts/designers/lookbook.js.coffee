class Lookbook

  @init: ->
    @bindContinueButton: ->
      $(".continue").click (e) =>
        e.preventDefault()
        $(".text-error").text('')
        @validateAndSubmit()

  @validateAndSubmit: ->
    bool = false
    can_submit = false
    $(".link_url").each ->
      url_value = $.trim($(this).val())
      if url_value.length > 1
        regex = /((ftp|http|https):\/\/)?(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
        unless regex.test(url_value)
          bool = true
          $(this).removeClass("alert-danger").addClass "alert-danger"
        else
          can_submit = true

    if bool
      alert "Please enter valid Link URL and make sure to add prefix http or https in URL"
      false
    else
      if can_submit
        $("#lookbook").submit()
        true
      else
        if $("[name='lookbook[picture][urls][]'],[name='lookbook[link][urls][]']").length > 0
          $("#lookbook").submit()
          true
        else
          alert "Please add atleast one picture or Link."
          false


  @setupImageUploader: ->
    $("#file_input").initUploader
      done: (event, data)=>
        for file in data.result.files
          @addThumb(file)

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
