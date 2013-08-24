const CRX_RELOAD_EXTENSION_ID = 'djacajifmnoecnnnpcgiilgnmobgnimn'

_gel = -> document.getElementById it

window.onload = ->
  host = _gel 'host'
  port = _gel 'port'
  restart = _gel 'restart'
  logger = _gel 'logger'

  socket = chrome.experimental.socket || chrome.socket
  var socketInfo

  stringToUint8Array = (string) ->
    buffer = new ArrayBuffer string.length
    view = new Uint8Array buffer
    for i til string.length
      view[i] = string.charCodeAt(i)
    return view

  arrayBufferToString = (buffer) ->
    str = ''
    uArrayVal = new Uint8Array buffer
    for s til uArrayVal.length
      str += String.fromCharCode uArrayVal[s]
    return str

  parseHTTPRequest = (data) ->
    if data isnt /^GET /
      return void
    pathEnd = data.indexOf ' ', 4
    if pathEnd < 0
      return void
    path = data.substring 4, pathEnd
    q = path.indexOf '?'
    if q != -1
      path = path.substring 0, q
    return {path: path}

  errorCodeName = (errorCode) ->
    | 200 => '200 OK'
    | 400 => '404 Not Found'
    | 503 => '503 Service Unavailable'
    | _ => '418 I\'m a teapot'

  HTTPResponse = (response) ->
    ['HTTP/1.0 ' + errorCodeName(response.errorCode),
     'Content-length: ' + response.content.length,
     'Content-type: text/plain',
     '',
     response.content].join '\n'

  writeResponse = (socketId, response) ->
    writeInfo <- socket.write socketId, stringToUint8Array(response).buffer
    console.log 'WRITE', writeInfo
    socket.destroy socketId
    socket.accept socketInfo.socketId, onAccept

  onAccept = (acceptInfo) ->
    console.log 'ACCEPT', acceptInfo
    readFromSocket acceptInfo.socketId

  readFromSocket = (socketId) ->
    readInfo <- socket.read socketId
    console.log 'READ', readInfo
    data = arrayBufferToString readInfo.data
    req = parseHTTPRequest data
    if req.path == '/favicon.ico'
      writeResponse socketId, HTTPResponse({
        errorCode: 404,
        content: 'no favicon'
      })
      return

    response <- chrome.runtime.sendMessage CRX_RELOAD_EXTENSION_ID, req
    if !response
      response =
          errorCode: 503,
          content: 'Did you install Crx Reloader Backend?\n' +
                   'https://chrome.google.com/webstore/detail/' +
                    CRX_RELOAD_EXTENSION_ID
    logToScreen response.content
    writeResponse socketId, HTTPResponse(response)

  start = ->
    _socketInfo <- socket.create 'tcp', {}
    socketInfo = _socketInfo;
    result <- socket.listen socketInfo.socketId, host.value, parseInt(port.value), 50
    logToScreen 'LISTENING: ' + result
    socket.accept socketInfo.socketId, onAccept

  updateInterfaces = ->
    interfaces <- socket.getNetworkList
    for i in interfaces
      iface = interfaces[i]
      opt = document.createElement 'option'
      opt.value = iface.address
      opt.innerText = "#{iface.name} - #{iface.address}"
      host.appendChild opt

  logToScreen = (msg) ->
    logger.textContent += msg + '\n'
    console.log msg

  restart.onclick = ->
    console.log 'RESTARTING'
    socket.destroy socketInfo.socketId
    start!

  start!
