// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#library("mongo_dart_server_lib");
#import("dart:io");
#import("dart:isolate");
#import("dart:json");
#import("dart:math");
#import("../../mongo.dart");
#import("../../bson.dart");

void startMongoDartServer() {
  var server = new MongoDartServer();
  server.init();
  port.receive(server.dispatch);
}

class MongoDartServer extends IsolatedServer {
}

class ServerMain {
  ServerMain.start(SendPort serverPort,
                   String hostAddress,
                   int tcpPort,
                   [int listenBacklog = 5])
      : _statusPort = new ReceivePort(),
        _serverPort = serverPort {
    // We can only guess this is the right URL. At least it gives a
    // hint to the session.
    print('Server starting http://${hostAddress}:${tcpPort}/');
    _start(hostAddress, tcpPort, listenBacklog);
  }

    void _start(String hostAddress, int tcpPort, int listenBacklog) {
    // Handle status messages from the server.
    _statusPort.receive((var message, SendPort replyTo) {
      String status = message.message;
      print("Received status: $status");
    });

    // Send server start message to the server.
    var command = new MongoDartServerCommand.start(hostAddress,
                                              tcpPort,
                                              backlog: listenBacklog);
    _serverPort.send(command, _statusPort.toSendPort());
  }

  void shutdown() {
    // Send server stop message to the server.
    _serverPort.send(new MongoDartServerCommand.stop(), _statusPort.toSendPort());
    _statusPort.close();
  }

  ReceivePort _statusPort;  // Port for receiving messages from the server.
  SendPort _serverPort;  // Port for sending messages to the server.
}


class Session {
  static int nextSessionId = 0;

  Session(this._handle) {
    _sessionId = "a${nextSessionId++}";
    markActivity();
  }

  void markActivity() { _lastActive = new Date.now(); }
  Duration idleTime(Date now) => now.difference(_lastActive);

  String get handle => _handle;
  String get sessionId => _sessionId;
  String _handle;
  String _sessionId;
  Date _lastActive;
}


class Message {
  static const int JOIN = 0;
  static const int MESSAGE = 1;
  static const int LEAVE = 2;
  static const int TIMEOUT = 3;
  static const int CONNECT = 4;
  static const List<String> _typeName =
      const [ "join", "message", "leave", "timeout", "connect"];

  Message.join(this._from)
      : _received = new Date.now(), _type = JOIN;
  Message.connect(this._from)
  : _received = new Date.now(), _type = CONNECT;
  Message(this._from, this._message)
      : _received = new Date.now(), _type = MESSAGE;
  Message.leave(this._from)
      : _received = new Date.now(), _type = LEAVE;
  Message.timeout(this._from)
      : _received = new Date.now(), _type = TIMEOUT;

  Session get from => _from;
  Date get received => _received;
  String get message => _message;
  void set messageNumber(int n) { _messageNumber = n; }

  Map toMap() {
    Map map = new Map();
    map["from"] = _from._handle;
    map["received"] = _received.toString();
    map["type"] = _typeName[_type];
    if (_type == MESSAGE) map["message"] = _message;
    map["number"] = _messageNumber;
    return map;
  }

  Session _from;
  Date _received;
  int _type;
  String _message;
  int _messageNumber;
}


class Topic {
  static const int DEFAULT_IDLE_TIMEOUT = 60 * 60 * 1000;  // One hour.
  Topic()
      : _activeSessions = new Map(),
        _messages = new List(),
        _nextMessageNumber = 0,
        _callbacks = new Map();

  int get activeSessions => _activeSessions.length;

  Session _sessionJoined(String handle) {
    Session session = new Session(handle);
    _activeSessions[session.sessionId] = session;
    Message message = new Message.join(session);
    _addMessage(message);
    return session;
  }

  Session _sessionLookup(String sessionId) => _activeSessions[sessionId];

  void _sessionLeft(String sessionId) {
    Session session = _sessionLookup(sessionId);
    Message message = new Message.leave(session);
    _addMessage(message);
    _activeSessions.remove(sessionId);
  }

  bool _addMessage(Message message) {
    message.messageNumber = _nextMessageNumber++;
    _messages.add(message);

    // Send the new message to all polling clients.
    List messages = new List();
    messages.add(message.toMap());
    _callbacks.forEach((String sessionId, Function callback) {
      callback(messages);
    });
    _callbacks = new Map();
  }

  bool _sessionMessage(Map requestData) {
    String sessionId = requestData["sessionId"];
    Session session = _sessionLookup(sessionId);
    if (session == null) return false;
    String uri = session.handle;
    String messageText = requestData["message"];
    if (messageText == null) return false;

    // Add new message.
    Message message = new Message(session, messageText);
    _addMessage(message);
    session.markActivity();

    return true;
  }

  List messagesFrom(int messageNumber, int maxMessages) {
    if (_messages.length > messageNumber) {
      if (maxMessages != null) {
        if (_messages.length - messageNumber > maxMessages) {
          messageNumber = _messages.length - maxMessages;
        }
      }
      List messages = new List();
      for (int i = messageNumber; i < _messages.length; i++) {
        messages.add(_messages[i].toMap());
      }
      return messages;
    } else {
      return null;
    }
  }

  void registerChangeCallback(String sessionId, var callback) {
    _callbacks[sessionId] = callback;
  }

  void _handleTimer(Timer timer) {
    Set inactiveSessions = new Set();
    // Collect all sessions which have not been active for some time.
    Date now = new Date.now();
    _activeSessions.forEach((String sessionId, Session session) {
      if (session.idleTime(now).inMilliseconds > DEFAULT_IDLE_TIMEOUT) {
        inactiveSessions.add(sessionId);
      }
    });
    // Terminate the inactive sessions.
    inactiveSessions.forEach((String sessionId) {
      Function callback = _callbacks.remove(sessionId);
      if (callback != null) callback(null);
      Session session = _activeSessions.remove(sessionId);
      Message message = new Message.timeout(session);
      _addMessage(message);
    });
  }

  Map<String, Session> _activeSessions;
  List<Message> _messages;
  int _nextMessageNumber;
  Map<String, Function> _callbacks;
}


class MongoDartServerCommand {
  static const START = 0;
  static const STOP = 1;

  MongoDartServerCommand.start(String this._host,
                          int this._port,
                          [int backlog = 5,
                           bool logging = false])
      : _command = START, _backlog = backlog, _logging = logging;
  MongoDartServerCommand.stop() : _command = STOP;

  bool get isStart => _command == START;
  bool get isStop => _command == STOP;

  String get host => _host;
  int get port => _port;
  bool get logging => _logging;
  int get backlog => _backlog;

  int _command;
  String _host;
  int _port;
  int _backlog;
  bool _logging;
}


class MongoDartServerStatus {
  static const STARTING = 0;
  static const STARTED = 1;
  static const STOPPING = 2;
  static const STOPPED = 3;
  static const ERROR = 4;

  MongoDartServerStatus(this._state, this._message);
  MongoDartServerStatus.starting() : _state = STARTING;
  MongoDartServerStatus.started(this._port) : _state = STARTED;
  MongoDartServerStatus.stopping() : _state = STOPPING;
  MongoDartServerStatus.stopped() : _state = STOPPED;
  MongoDartServerStatus.onError([this._error]) : _state = ERROR;

  bool get isStarting => _state == STARTING;
  bool get isStarted => _state == STARTED;
  bool get isStopping => _state == STOPPING;
  bool get isStopped => _state == STOPPED;
  bool get isError => _state == ERROR;

  int get state => _state;
  String get message {
    if (_message != null) return _message;
    switch (_state) {
      case STARTING: return "Server starting";
      case STARTED: return "Server listening";
      case STOPPING: return "Server stopping";
      case STOPPED: return "Server stopped";
      case ERROR:
        if (_error == null) {
          return "Server error";
        } else {
          return "Server error: $_error";
        }
    }
  }

  int get port => _port;
  Dynamic get error => _error;

  int _state;
  String _message;
  int _port;
  var _error;
}


class IsolatedServer {
  static const String redirectPageHtml = """
<html>
<head><title>Welcome to the mongo_dart server</title></head>
<body><h1>Welcome to the mongo_dart server</h1></body>
</html>""";
  static const String notFoundPageHtml = """
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL was not found on this server.</p>
</body></html>""";

  void _sendJSONResponse(HttpResponse response, responseData) {
    response.headers.set("Content-Type", "application/json; charset=UTF-8");
    response.outputStream.writeString(JSON.stringify(responseData));
    response.outputStream.close();
  }

  void redirectPageHandler(HttpRequest request,
                           HttpResponse response,
                           String redirectPath) {
    if (_redirectPage == null) {
      _redirectPage = redirectPageHtml.charCodes();
    }
//    response.statusCode = HttpStatus.FOUND;
//    response.headers.set(
//        "Location", "http://$_host:$_port/${redirectPath}");
    response.contentLength = _redirectPage.length;
    response.outputStream.write(_redirectPage);
    response.outputStream.close();
  }

  // Serve the content of a file.
  void fileHandler(
      HttpRequest request, HttpResponse response, [String fileName = null]) {
    final int BUFFER_SIZE = 4096;
    if (fileName == null) {
      fileName = request.path.substring(1);
    }
    File file = new File(fileName);
    if (file.existsSync()) {
      String mimeType = "text/html; charset=UTF-8";
      int lastDot = fileName.lastIndexOf(".", fileName.length);
      if (lastDot != -1) {
        String extension = fileName.substring(lastDot);
        if (extension == ".css") { mimeType = "text/css"; }
        if (extension == ".js") { mimeType = "application/javascript"; }
        if (extension == ".ico") { mimeType = "image/vnd.microsoft.icon"; }
        if (extension == ".png") { mimeType = "image/png"; }
      }
      response.headers.set("Content-Type", mimeType);
      // Get the length of the file for setting the Content-Length header.
      RandomAccessFile openedFile = file.openSync();
      response.contentLength = openedFile.lengthSync();
      openedFile.closeSync();
      // Pipe the file content into the response.
      file.openInputStream().pipe(response.outputStream);
    } else {
      print("File not found: $fileName");
      _notFoundHandler(request, response);
    }
  }

  // Serve the not found page.
  void _notFoundHandler(HttpRequest request, HttpResponse response) {
    if (_notFoundPage == null) {
      _notFoundPage = notFoundPageHtml.charCodes();
    }
    response.statusCode = HttpStatus.NOT_FOUND;
    response.headers.set("Content-Type", "text/html; charset=UTF-8");
    response.contentLength = _notFoundPage.length;
    response.outputStream.write(_notFoundPage);
    response.outputStream.close();
  }

  // Unexpected protocol data.
  void _protocolError(HttpRequest request, HttpResponse response) {
    response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
    response.contentLength = 0;
    response.outputStream.close();
  }

  // Join request:
  // { "request": "join",
  //   "uri": <uri> }
  void _joinHandler(HttpRequest request, HttpResponse response) {
    StringBuffer body = new StringBuffer();
    StringInputStream input = new StringInputStream(request.inputStream);
    input.onData = () => body.add(input.read());
    input.onClosed = () {
      String data = body.toString();
      if (data != null) {
        var requestData = JSON.parse(data);
        if (requestData["request"] == "join") {
          String handle = requestData["handle"];
          if (handle != null) {
            // New session joining.
            Session session = _topic._sessionJoined(handle);

            // Send response.
            Map responseData = new Map();
            responseData["response"] = "join";
            responseData["sessionId"] = session.sessionId;
            _sendJSONResponse(response, responseData);
          } else {
            _protocolError(request, response);
          }
        } else {
          _protocolError(request, response);
        }
      } else {
        _protocolError(request, response);
      }
    };
  }

  // Connect request:
  // { "request": "connect",
  //   "uri": <MongoDbUri> }
  void _connectHandler(HttpRequest request, HttpResponse response) {
    StringBuffer body = new StringBuffer();
    StringInputStream input = new StringInputStream(request.inputStream);
    input.onData = () => body.add(input.read());
    input.onClosed = () {
      String data = body.toString();
      if (data != null) {
        var requestData = JSON.parse(data);
        if (requestData["request"] == "connect") {
          String uri = requestData["uri"];
          if (uri != null) {
            // New session joining.
            Session session = _topic._sessionJoined(uri);
            // Send response.
            Map responseData = new Map();
            responseData["response"] = "connect";
            responseData["sessionId"] = session.sessionId;
            _sendJSONResponse(response, responseData);
          } else {
            _protocolError(request, response);
          }
        } else {
          _protocolError(request, response);
        }
      } else {
        _protocolError(request, response);
      }
    };
  }



 String _getCollectionFromRequest(HttpRequest request) {
   var collection = request.path.split("/")[1];
   return collection;
 }
 
 void _saveHandler(HttpRequest request, HttpResponse response) {
   String createdId;
   StringBuffer body = new StringBuffer();
   StringInputStream input = new StringInputStream(request.inputStream);
   input.onData = () => body.add(input.read());
   input.onClosed = () {
     String data = body.toString();
     if (data != null) {
       var mapToSave = JSON.parse(data);
       var collection = _getCollectionFromRequest(request);
       if (mapToSave !== null && collection !== null) {
         if (mapToSave["_id"] === null) {
           createdId = new ObjectId().toHexString(); 
           mapToSave["_id"] = createdId;
           db.collection(collection).insert(mapToSave);
         } else {
           db.collection(collection).save(mapToSave);     
         }       
         db.getLastError().then((responseData) {
           if (createdId !== null) {
             responseData["createdId"] = createdId;
           } 
           _sendJSONResponse(response, responseData);
         });
       } else {
         _protocolError(request, response);
       }
     } else {
       _protocolError(request, response);
     }
   };
 }

 void _removeHandler(HttpRequest request, HttpResponse response) {
   StringBuffer body = new StringBuffer();
   StringInputStream input = new StringInputStream(request.inputStream);
   input.onData = () => body.add(input.read());
   input.onClosed = () {
     String data = body.toString();
     if (data != null) {
       var requestData = JSON.parse(data);
       var collection = _getCollectionFromRequest(request);
       if (requestData !== null && collection !== null) {
         db.collection(collection).remove(requestData);     
         db.getLastError().then((responseData) {
           _sendJSONResponse(response, responseData);
         });
       } else {
         _protocolError(request, response);
       }
     } else {
       _protocolError(request, response);
     }
   };
 }

 

 void _findOneHandler(HttpRequest request, HttpResponse response) {   
   StringBuffer body = new StringBuffer();
   StringInputStream input = new StringInputStream(request.inputStream);
   input.onData = () => body.add(input.read());
   input.onClosed = () {
     String data = body.toString();
     if (data != null) {
       var requestData = JSON.parse(data);
       var collection = _getCollectionFromRequest(request);
       if (requestData !== null && collection !== null) {
         db.collection(collection).findOne(requestData).
          then((responseData) {
           _sendJSONResponse(response, responseData);
         });
       } else {
         _protocolError(request, response);
       }
     } else {
       _protocolError(request, response);
     }
   };
 }

 void _findHandler(HttpRequest request, HttpResponse response) {   
   StringBuffer body = new StringBuffer();
   StringInputStream input = new StringInputStream(request.inputStream);
   input.onData = () => body.add(input.read());
   input.onClosed = () { 
     String data = body.toString();
     if (data != null) {
       var requestData = JSON.parse(data);   
       var collection = _getCollectionFromRequest(request);
       if (requestData !== null && collection !== null) {
         db.collection(collection).find(requestData).toList().
          then((responseData) {       
           _sendJSONResponse(response, responseData);          
         });
       } else {
         _protocolError(request, response);
       }
     } else {
       _protocolError(request, response);
     }
   };
 }

 

  // Leave request:
  // { "request": "leave",
  //   "sessionId": <sessionId> }
  void _leaveHandler(HttpRequest request, HttpResponse response) {
    print("leaveHandler");
    StringBuffer body = new StringBuffer();
    StringInputStream input = new StringInputStream(request.inputStream);
    input.onData = () => body.add(input.read());
    input.onClosed = () {
      String data = body.toString();
      var requestData = JSON.parse(data);
      if (requestData["request"] == "leave") {
        String sessionId = requestData["sessionId"];
        if (sessionId != null) {
          // Session leaving.
          _topic._sessionLeft(sessionId);

          // Send response.
          Map responseData = new Map();
          responseData["response"] = "leave";
          _sendJSONResponse(response, responseData);
        } else {
          _protocolError(request, response);
        }
      } else {
        _protocolError(request, response);
      }
    };
  }

  // Message request:
  // { "request": "message",
  //   "sessionId": <sessionId>,
  //   "message": <message> }
  void _messageHandler(HttpRequest request, HttpResponse response) {
    StringBuffer body = new StringBuffer();
    StringInputStream input = new StringInputStream(request.inputStream);
    input.onData = () => body.add(input.read());
    input.onClosed = () {
      String data = body.toString();
      _messageCount++;
      _messageRate.record(1);
      var requestData = JSON.parse(data);
      if (requestData["request"] == "message") {
        String sessionId = requestData["sessionId"];
        if (sessionId != null) {
          // New message from session.
          bool success = _topic._sessionMessage(requestData);

          // Send response.
          if (success) {
            Map responseData = new Map();
            responseData["response"] = "message";
            _sendJSONResponse(response, responseData);
          } else {
            _protocolError(request, response);
          }
        } else {
          _protocolError(request, response);
        }
      } else {
        _protocolError(request, response);
      }
    };
  }

  // Receive request:
  // { "request": "receive",
  //   "sessionId": <sessionId>,
  //   "nextMessage": <nextMessage>,
  //   "maxMessages": <maxMesssages> }
  void _receiveHandler(HttpRequest request, HttpResponse response) {
    StringBuffer body = new StringBuffer();
    StringInputStream input = new StringInputStream(request.inputStream);
    input.onData = () => body.add(input.read());
    input.onClosed = () {
      String data = body.toString();
      var requestData = JSON.parse(data);
      if (requestData["request"] == "receive") {
        String sessionId = requestData["sessionId"];
        int nextMessage = requestData["nextMessage"];
        int maxMessages = requestData["maxMessages"];
        if (sessionId != null && nextMessage != null) {

          void sendResponse(messages) {
            // Send response.
            Map responseData = new Map();
            responseData["response"] = "receive";
            if (messages != null) {
              responseData["messages"] = messages;
              responseData["activeSessions"] = _topic.activeSessions;
              responseData["upTime"] =
                  new Date.now().difference(_serverStart).inMilliseconds;
            } else {
              responseData["disconnect"] = true;
            }
            _sendJSONResponse(response, responseData);
          }

          // Receive request from session.
          List messages = _topic.messagesFrom(nextMessage, maxMessages);
          if (messages == null) {
            _topic.registerChangeCallback(sessionId, sendResponse);
          } else {
            sendResponse(messages);
          }

        } else {
          _protocolError(request, response);
        }
      } else {
        _protocolError(request, response);
      }
    };
  }

  void init() {
    _logRequests = false;
    _topic = new Topic();
    _serverStart = new Date.now();
    _messageCount = 0;
    _messageRate = new Rate();
    db = new Db('mongodb://127.0.0.1/mongo_dart_server');
    db.open().then((_) {
      print("MongoDb openened on ${db.databaseName}");
    });
    // Start a timer for cleanup events.
    _cleanupTimer =
        new Timer.repeating(10000, (timer) => _topic._handleTimer(timer));
  }

  // Start timer for periodic logging.
  void _handleLogging(Timer timer) {
    if (_logging) {
      print("${_messageRate.rate} messages/s "
            "(total $_messageCount messages)");
    }
  }

  void dispatch(message, replyTo) {
    if (message.isStart) {
      _host = message.host;
      _port = message.port;
      _logging = message.logging;
      replyTo.send(new MongoDartServerStatus.starting(), null);
      _server = new HttpServer();
      _server.defaultRequestHandler = _notFoundHandler;
      _server.addRequestHandler(
          (request) => request.path == "/",
          (HttpRequest request, HttpResponse response) =>
              redirectPageHandler(
                  request, response, "/"));
      _server.addRequestHandler(
          (request) => request.path == "/connect", _connectHandler);
      _server.addRequestHandler(
          (request) => request.path.endsWith("/save"), _saveHandler);
      _server.addRequestHandler(
          (request) => request.path.endsWith("/remove"), _removeHandler);      
      _server.addRequestHandler(
          (request) => request.path.endsWith("/findOne"), _findOneHandler);
      _server.addRequestHandler(
          (request) => request.path.endsWith("/find"), _findHandler);      
      try {
        _server.listen(_host, _port, backlog: message.backlog);
        replyTo.send(new MongoDartServerStatus.started(_server.port), null);
        _loggingTimer = new Timer.repeating(1000, _handleLogging);
      } catch (e) {
        replyTo.send(new MongoDartServerStatus.onError(e.toString()), null);
      }
    } else if (message.isStop) {
      replyTo.send(new MongoDartServerStatus.stopping(), null);
      stop();
      replyTo.send(new MongoDartServerStatus.stopped(), null);
    }
  }

  stop() {
    _server.close();
    _cleanupTimer.cancel();
    db.close();
    port.close();
  }

  String _host;
  int _port;
  HttpServer _server;  // HTTP server instance.
  bool _logRequests;

  Topic _topic;
  Timer _cleanupTimer;
  Timer _loggingTimer;
  Date _serverStart;

  bool _logging;
  int _messageCount;
  Rate _messageRate;
  Db db;
  // Static HTML.
  List<int> _redirectPage;
  List<int> _notFoundPage;
}


// Calculate the rate of events over a given time range. The time
// range is split over a number of buckets where each bucket collects
// the number of events happening in that time sub-range. The first
// constructor arument specifies the time range in milliseconds. The
// buckets are in the list _buckets organized at a circular buffer
// with _currentBucket marking the bucket where an event was last
// recorded. A current sum of the content of all buckets except the
// one pointed a by _currentBucket is kept in _sum.
class Rate {
  Rate([int timeRange = 1000, int buckets = 10])
      : _timeRange = timeRange,
        _buckets = new List(buckets + 1),  // Current bucket is not in the sum.
        _currentBucket = 0,
        _currentBucketTime = new Date.now().millisecondsSinceEpoch,
        _sum = 0 {
    _bucketTimeRange = (_timeRange / buckets).toInt();
    for (int i = 0; i < _buckets.length; i++) {
      _buckets[i] = 0;
    }
  }

  // Record the specified number of events.
  void record(int count) {
    _timePassed();
    _buckets[_currentBucket] = _buckets[_currentBucket] + count;
  }

  // Returns the current rate of events for the time range.
  num get rate {
    _timePassed();
    return _sum;
  }

  // Update the current sum as time passes. If time has passed by the
  // current bucket add it to the sum and move forward to the bucket
  // matching the current time. Subtract all buckets vacated from the
  // sum as bucket for current time is located.
  void _timePassed() {
    int time = new Date.now().millisecondsSinceEpoch;
    if (time < _currentBucketTime + _bucketTimeRange) {
      // Still same bucket.
      return;
    }

    // Add collected bucket to the sum.
    _sum += _buckets[_currentBucket];

    // Find the bucket for the current time. Subtract all buckets
    // reused from the sum.
    while (time >= _currentBucketTime + _bucketTimeRange) {
      _currentBucket = (_currentBucket + 1) % _buckets.length;
      _sum -= _buckets[_currentBucket];
      _buckets[_currentBucket] = 0;
      _currentBucketTime += _bucketTimeRange;
    }
  }

  int _timeRange;
  List<int> _buckets;
  int _currentBucket;
  int _currentBucketTime;
  num _bucketTimeRange;
  int _sum;
}
