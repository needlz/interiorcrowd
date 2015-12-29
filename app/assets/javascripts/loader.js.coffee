window.require = (requiredVars, func) ->
  window.funcRequirements = window.funcRequirements or []
  window.funcRequirements.push
    flags: requiredVars
    func: func
  firePostponedFuncs()
  return

window.defined = ->
  firePostponedFuncs()

tryFirePostponedFunc = (funcIndex) ->
  if !$.isArray(window.funcRequirements)
    return
  funcReq = window.funcRequirements[funcIndex]
  len = funcReq.flags.length
  i = 0
  while i < len
    return unless window[funcReq.flags[i]]
    i++
  setTimeout funcReq.func, 0
  # prevent race condition
  true

firePostponedFuncs = ->
  if window.funcRequirements
    window.funcRequirements = $.grep(window.funcRequirements, ((_, funcIndex) ->
      tryFirePostponedFunc funcIndex
    ), true)
  return
