Log4Dart
========
**Log4Dart** is a logger for Dart inspired by [Slf4J][slf4j]. 

The logger and its appender are interfaces and thus supports multiple implementations. The following 
implementations are included

  * **ConsoleAppender** Appender that logs to the console
  * **FileAppender** Appender that logs to a file (to use this appender your app must import **dart:io**) 
  * **LoggerImpl** Default log implementation with support for multiple appenders and diagnostic

Getting started
---------------
The logger is accessed through  the **LoggerFactory** 

```
class MyClass {
  final Logger _logger;

  MyClass(): _logger = LoggerFactory.getLogger("MyClass");

  someMethod() {
    _logger.info("a info message");
  }
}
```

Log configuration
-----------------
By default the **LoggerFactory** will return a logger that logs to the
console, with all log levels enabled. If you need a different logger or
dislike the default settings then you can configure the
**LoggerFactory's** builder function. This is the method invoked by the
factory when asked for a logger 

```
LoggerFactory.builder = (name) => new LoggerImpl(name, debugEnabled:false); 
```

You can use this to return different loggers for different classes

```
LoggerFactory.builder = (name) {
  if(name == "ClassThatMakesAllotOfNoise") return new LoggerImpl(name, debugEnabled:false, infoEnabled:false);
  if(name == "ClassWithProblems") return new LoggerImpl(name, debugEnabled:true);
  // default logger for the rest
  return new LoggerImpl(name, debugEnabled:false, appenders:[new FileAppender("log.txt")]);
}; 
```

For more information see the **TestRunner.dart** class in the **test** folder

Diagnostic support
------------------
The logger supports nested diagnostic contexts which can be used to
track application state like this

```
logger.putContext("context-name", "context-message");
try {
  // log messages from now gets added a context-message
  :
  logger.debug("something important happend");
} finally {
  // stop logging with context-message
  logger.removeContext("context-name");
}
```

A running example of this can be seen in the **ContextLogTest.dart** class in the **test** folder.

TODO
----
Some missing stuff (feel free to add more):

  1. Generate DartDoc for Logger and Appender interface
  1. Create a Dart version of **sprintf** and use it for implementing the formatters 
  1. Figure out how best to configure the log output format
  1. When reflection arrives in Dart add ability to show the class/line where the log message originated

feel free to send in patched for these (or other features you miss).

License
-------
BSD License (Same as Dart itself). See LICENSE file.  

[slf4j]: http://www.slf4j.org/
