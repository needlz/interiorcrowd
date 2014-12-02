window.digitsFilter = (event)->
  char = String.fromCharCode(event.which)
  event.preventDefault() unless char.match(/[0-9]/)
