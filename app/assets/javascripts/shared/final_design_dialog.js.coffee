class @FulfillmentDesign
  @submit: ->
    id = $('.moveToFinal').attr('request_id')
    $.ajax(
      data: { id: id }
      url: "/contest_requests/#{id}/approve_fulfillment"
      type: 'POST'
      success: (data)->
        mixpanel.track('Products list approved', { contest_request_id: id })
        location.reload();
    )

$(document).ready ->
  $('#finishContest').on('click', '.no-button', (event)->
    event.preventDefault()
    $('#finishContest').modal('hide');
  ).on('click', '.yes-button', (event)->
    event.preventDefault()
    FulfillmentDesign.submit()
  )

  $('.moveToFinal').on 'click', ->
    $('#finishContest').modal('show')
