class @FulfillmentDesign
  @submit: ->
    id = $('.submitMyDesign').attr('request_id')
    $.ajax(
      data: { id: id }
      url: "/contest_requests/#{id}/approve_fulfillment"
      type: 'POST'
      success: (data)->
        location.reload();
    )

$(document).ready ->
  $('#finalizeConfirmation').on('click', '.no-button', (event)->
    event.preventDefault()
    $('#finalizeConfirmation').modal('hide');
  ).on('click', '.yes-button', (event)->
    event.preventDefault()
    FulfillmentDesign.submit()
  )

  $('.submitMyDesign').on 'click', ->
    $('#finalizeConfirmation').modal('show')
