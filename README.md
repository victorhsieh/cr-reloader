# Crx Reloader

## Install

You will need to install both due to Chrome API restriction.

 * [Crx Reloader](https://chrome.google.com/webstore/detail/crx-reloader/gmmimkfknamjlkfclhbjojlbmiijcmgm)
 * [Crx Reloader Backend](https://chrome.google.com/webstore/detail/crx-reloader-backend/djacajifmnoecnnnpcgiilgnmobgnimn)

## Usage

Simply click on the icon of Crx Reloader.  After that, you can restart your extension or app by firing HTTP request.

For example, the following command will restart the corresponding extension (or packaged app).

 > curl http://localhost:24601/abcdefghijklmnopqrstuvwxy
