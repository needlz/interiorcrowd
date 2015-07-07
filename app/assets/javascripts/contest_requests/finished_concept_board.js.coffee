$ ->
  PicturesZoom.init('.enlarge')

  $('#final-note-to-designer').on 'ajax:success', (e)->
    $('#final-note-to-designer textarea').val('')
