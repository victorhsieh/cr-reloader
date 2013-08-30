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
