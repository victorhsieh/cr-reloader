const ROUTER_EXTENSION_ID = "gmmimkfknamjlkfclhbjojlbmiijcmgm";

console.log('Start listening');
chrome.runtime.onMessageExternal.addListener(function(req, sender, sendResponse) {
  if (sender.id != ROUTER_EXTENSION_ID)
    return false;
  var id = req.path.substring(1);
  if (!id || id == 'favicon.ico') {
    console.log('Extension not found', id);
    sendResponse({'errorCode': 404, 'content': 'invalid id'});
    return false;
  }
  chrome.management.get(id, function(ext_info) {
    if (!ext_info) {
      sendResponse({'errorCode': 404, 'content': 'No such app' + id});
      return;
    }
    chrome.management.setEnabled(id, false, function() {
      chrome.management.setEnabled(id, true, function() {
        if (ext_info.type == 'packaged_app') {
          chrome.management.launchApp(id, function() {
            console.log('Re-launched app', id);
            sendResponse({'errorCode': 200, 'content': 'Re-launched ' + id});
          });
        } else {
          sendResponse({'errorCode': 200, 'content': 'Re-launched ' + id});
        }
      });
    });
  });
  return true;
});
