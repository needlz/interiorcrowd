class @ContestEditing

  bindEditPopovers: ->
    $('.edit-label').click ->
      $button = $(@)
      option = $button.parents('[data-option]').attr('data-option')
      $.ajax(
        data: { option: option }
        url: "/contests/#{ @contestId }/option"
        success: (data)->
          $button.parents('.row[data-option]').html(data)
      )

  contestId: ->
    $('.contest').attr('data-id')

$ ->
  brief = new ContestEditing()
  brief.bindEditPopovers()

  $('.colors').colorTags({ readonly: true })
