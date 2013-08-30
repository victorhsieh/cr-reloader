const ROUTER_EXTENSION_ID = 'gmmimkfknamjlkfclhbjojlbmiijcmgm'

console.log 'Start listening'

reload_url = (url, sendResponse) ->
  tabs <- chrome.tabs.query {url: url}

  if tabs.length != 1
    console.log 'Matched tabs:', tabs
    reason = if tabs.length == 0 then 'No matched url.'
                                 else 'Please provide more specific pattern.'
    sendResponse {
      errorCode: 429,
      content: reason +
               ' See http://developer.chrome.com/extensions/match_patterns.html'
    }
    return

  chrome.tabs.reload tabs[0].id, {}, ->
    sendResponse {errorCode: 200, content: 'Reloaded: ' + tabs[0].url}


reload_ext_or_app = (id, sendResponse) ->
  ext_info <- chrome.management.get id

  if !ext_info
    sendResponse {errorCode: 404, content: "No such app #id"}
    return

  # Reload
  <- chrome.management.setEnabled id, false
  <- chrome.management.setEnabled id, true

  if ext_info.type == 'packaged_app'
    chrome.management.launchApp id, ->
      sendResponse {errorCode: 200, content: "Re-launched #id"}
  else
    sendResponse {errorCode: 200, content: "Re-launched #id"}


chrome.runtime.onMessageExternal.addListener (req, sender, sendResponse) ->
  if sender.id != ROUTER_EXTENSION_ID and localStorage['dev_mode'] !== 'true'
    sendResponse {errorCode: 403, content: 'Forbidden'}
    return false

  if req.pathname == '/r'
    if req.query.url?
      reload_url req.query.url, sendResponse
      return true
    if req.query.ext?
      reload_ext_or_app req.query.ext, sendResponse
      return true

  id = req.pathname.substring 1
  if !id
    console.log 'Extension not found', id
    sendResponse {errorCode: 404, content: 'invalid id'}
    return false

  reload_ext_or_app id, sendResponse
  return true
