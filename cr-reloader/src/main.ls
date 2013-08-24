<- chrome.app.runtime.onLaunched.addListener
chrome.app.window.create 'index.html', bounds: { width: 500, height: 500 }
