#= require active_admin/base

$ ->
  $emailFilterInput = $('.admin_designers #q_email')
  $emailFilterInput.clone().css('display', 'none').insertBefore($emailFilterInput)
