#= require active_admin/base

$ ->
  $('#edit_designer textarea#designer_email').attr('name', 'designer[ema_il]')
  $('form#edit_designer').submit ->
    $('#edit_designer textarea#designer_email').attr('name', 'designer[email]')
