const CRX_RELOAD_EXTENSION_ID = 'djacajifmnoecnnnpcgiilgnmobgnimn';

onload = function() {
  var hosts = document.getElementById("hosts");
  var port = document.getElementById("port");
  var restart = document.getElementById('restart');
  var logger = document.getElementById('logger');

  var socket = chrome.experimental.socket || chrome.socket;
  var socketInfo;

  function stringToUint8Array(string) {
    var buffer = new ArrayBuffer(string.length);
    var view = new Uint8Array(buffer);
    for(var i = 0; i < string.length; i++) {
      view[i] = string.charCodeAt(i);
    }
    return view;
  }

  function arrayBufferToString(buffer) {
    var str = '';
    var uArrayVal = new Uint8Array(buffer);
    for(var s = 0; s < uArrayVal.length; s++) {
      str += String.fromCharCode(uArrayVal[s]);
    }
    return str;
  }

  function parseHTTPRequest(data) {
    if (data.indexOf("GET ") != 0)
      return null;
    var pathEnd = data.indexOf(" ", 4);
    if (pathEnd < 0) { return null; }
    var path = data.substring(4, pathEnd);
    var q = path.indexOf("?");
    if (q != -1)
      path = path.substring(0, q);
    return {'path': path}
  }

  function resultFormat(response) {
    if (response.errorCode == 200)
      return "200 OK";
    else if (response.errorCode == 400)
      return "404 Not Found";
    else if (response.errorCode == 503)
      return "503 Service Unavailable";
    return "418 I'm a teapot";
  }

  function HTTPResponse(response) {
    return ["HTTP/1.0 " + resultFormat(response),
           "Content-length: " + response.content.length,
           "Content-type: text/plain",
           "",
           response.content].join("\n");
  }

  function writeResponse(socketId, response) {
    socket.write(socketId, stringToUint8Array(response).buffer, function(writeInfo) {
      console.log("WRITE", writeInfo);
      socket.destroy(socketId);
      socket.accept(socketInfo.socketId, onAccept);
    });
  }

  function onAccept(acceptInfo) {
    console.log("ACCEPT", acceptInfo)
    readFromSocket(acceptInfo.socketId);
  }

  function readFromSocket(socketId) {
    socket.read(socketId, function(readInfo) {
      console.log("READ", readInfo);
      var data = arrayBufferToString(readInfo.data);
      var req = parseHTTPRequest(data);
      if (req.path == '/favicon.ico') {
        writeResponse(socketId, HTTPResponse({
          'errorCode': 404,
          'content': 'no favicon'
        }));
        return;
      }
      chrome.runtime.sendMessage(CRX_RELOAD_EXTENSION_ID, req, function(response) {
        if (!response) {
          response = {
            'errorCode': 503,
            'content': 'Did you install Crx Reloader Backend?\n' +
                       'https://chrome.google.com/webstore/detail/' +
                       CRX_RELOAD_EXTENSION_ID
          };
        }
        logToScreen(response.content);
        writeResponse(socketId, HTTPResponse(response));
      });
    });
  }

  function start() {
    socket.create("tcp", {}, function(_socketInfo) {
      socketInfo = _socketInfo;
      socket.listen(socketInfo.socketId, hosts.value, parseInt(port.value), 50, function(result) {
        logToScreen("LISTENING: " + result);
        socket.accept(socketInfo.socketId, onAccept);
      });
    });
  }

  function updateInterfaces() {
    socket.getNetworkList(function(interfaces) {
      for (var i in interfaces) {
        var interface = interfaces[i];
        var opt = document.createElement("option");
        opt.value = interface.address;
        opt.innerText = interface.name + " - " + interface.address;
        hosts.appendChild(opt);
      }
    });
  }

  function logToScreen(msg) {
    logger.textContent += msg + "\n";
    console.log(msg);
  }

  restart.onclick = function() {
    console.log("RESTARTING");
    socket.destroy(socketInfo.socketId);
    start();
  };

  start();
};
