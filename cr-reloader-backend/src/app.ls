const ROUTER_EXTENSION_ID = 'gmmimkfknamjlkfclhbjojlbmiijcmgm'

console.log 'Start listening'

chrome.runtime.onMessageExternal.addListener (req, sender, sendResponse) ->
  if sender.id != ROUTER_EXTENSION_ID and localStorage['dev_mode'] !== 'true'
    sendResponse {errorCode: 403, content: 'Forbidden'}
    return false

  id = req.pathname.substring 1
  if !id
    console.log 'Extension not found', id
    sendResponse {errorCode: 404, content: 'invalid id'}
    return false

  chrome.management.get id, (ext_info) ->
    if !ext_info
      sendResponse {errorCode: 404, content: 'No such app' + id}
      return

    <- chrome.management.setEnabled id, false
    <- chrome.management.setEnabled id, true

    if ext_info.type == 'packaged_app'
      <- chrome.management.launchApp id
      console.log 'Re-launched app', id
      sendResponse {errorCode: 200, content: 'Re-launched ' + id}
    else
      sendResponse {errorCode: 200, content: 'Re-launched ' + id}

  return true
