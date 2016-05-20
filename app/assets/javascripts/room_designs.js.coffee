class roomDesign

  @init: ->
    bindFormSubmit()

  bindFormSubmit= ->
    $('#room-creation-from').on 'ajax:success', (event, data)->
      $('#roomCreationModal').modal('toggle');
      $('.items').prepend(data.new_room_html)
      $('.no-room-description').hide()
$ ->
  roomDesign.init()
