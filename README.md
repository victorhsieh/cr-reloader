# Cr Reloader

## Install

You will need to install both due to Chrome API restriction.

 * [Cr Reloader](https://chrome.google.com/webstore/detail/cr-reloader/gmmimkfknamjlkfclhbjojlbmiijcmgm)
 * [Cr Reloader Backend](https://chrome.google.com/webstore/detail/cr-reloader-backend/djacajifmnoecnnnpcgiilgnmobgnimn)

## Usage

Simply click on the icon of Cr Reloader to launch the web server.  Now you can restart your extension, app or web page by firing HTTP request.

For example, the following command will restart the corresponding extension (or packaged app):

 > curl http://localhost:24601/r?ext=abcdefghijklmnopqrstuvwxy

If you want to reload a web page, here is the query:

 > curl http://localhost:24601/r?url=*://www.google.com/*

URL pattern is defined in [this page](http://developer.chrome.com/extensions/match_patterns.html).

## Development

To impersonate the published crx id locally, add the following snippet to override public keys in manifest.json.

 * For Cr Reloader:

 > "key": "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCVOafQa42wgDfzrFZgncOkmgsjq3GnC7fIJdmlTshIPYbHet+4DySX08GLkkLUan0tIfWILJHwt9ws5sroC178ynq/ljhLCkiuSlO/dzdjs5PeyikL17QLYRbL3DTzKbz79LuFiFWOTIL7kwYFkeSCVFyPukGRoEa36MmWMyTs1QIDAQAB",

 * For Cr Reloader Backend:

 > "key": "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCDPVF5nruqpoYX3VetQCFC0f3y0fYXfmY/PjP4IdTx1NQEmGzq7/gxn1MkbSvB/djaWBG0T1O07FD7/SegFjIY7w5/caE7ECn79CGW0yC+R3EIPm4mcf6BjbVcx4TfHg47HS1c6Fzv1mkOAyGJt77cne60k94fZZHAo7JQ2rHkXQIDAQAB",
