require! url

const CRX_RELOAD_EXTENSION_ID = 'djacajifmnoecnnnpcgiilgnmobgnimn'
const PORT = 24601

_gel = -> document.getElementById it

window.onload = ->
  restart = _gel 'restart'
  logger = _gel 'logger'

  tcpServer = chrome.sockets.tcpServer
  tcp = chrome.sockets.tcp

  var serverSocketId

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
    full_url= data.substring 4, pathEnd
    return url.parse full_url, true, true

  errorCodeName = (errorCode) ->
    | 200 => '200 OK'
    | 403 => '403 Forbidden'
    | 404 => '404 Not Found'
    | 503 => '503 Service Unavailable'
    | _ => '418 I\'m a teapot'

  HTTPResponse = (response) ->
    ['HTTP/1.0 ' + errorCodeName(response.errorCode),
     'Content-length: ' + response.content.length,
     'Content-type: text/plain',
     '',
     response.content].join '\n'

  writeResponse = (socketId, response) ->
    console.log 'Sending back', socketId
    info <- chrome.sockets.tcp.send socketId, stringToUint8Array(response).buffer
    if info.resultCode != 0
      console.error 'Failed to send to tcp socket, error code ' + info.resultCode
    chrome.sockets.tcp.close socketId

  onAccept = (acceptInfo) ->
    console.log 'Accept', acceptInfo.clientSocketId
    chrome.sockets.tcp.onReceive.addListener onReceive
    chrome.sockets.tcp.setPaused acceptInfo.clientSocketId, false

  onReceive = (info) ->
    console.log 'Receiving from', info.socketId
    data = arrayBufferToString info.data
    req = parseHTTPRequest data
    if req.pathname == '/favicon.ico'
      writeResponse info.socketId, HTTPResponse({
        errorCode: 404,
        content: 'no favicon'
      })
      return

    backend = req.query.backend || CRX_RELOAD_EXTENSION_ID
    response <- chrome.runtime.sendMessage backend, req
    if !response
      response =
          errorCode: 503,
          content: 'Did you install Crx Reloader Backend?\n' +
                   'https://chrome.google.com/webstore/detail/' +
                    CRX_RELOAD_EXTENSION_ID
    logToScreen 'Response content: [' + response.content + ']'
    writeResponse info.socketId, HTTPResponse(response)

  start = ->
    info <- tcpServer.create {}
    serverSocketId := info.socketId
    host = _gel 'host'
    result <- tcpServer.listen info.socketId, host.value, PORT
    logToScreen 'Listening: ' + result

    chrome.sockets.tcpServer.onAccept.addListener (info) ->
      onAccept info
    chrome.sockets.tcpServer.onAcceptError.addListener (info) ->
      logToScreen "Accept error: socket: #{info.socketId} result: #{info.resultCode}"

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
    console.log 'Restarting'
    tcpServer.disconnect serverSocketId
    start!

  start!
