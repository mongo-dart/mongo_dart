// Copyright (c) 2012 Qalqo, all rights reserved.  
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Utility class for producing Loggers for various logging implementations
 * 
 * Unless otherwise specified it defaults to the bundled LoggerImpl
 */
class LoggerFactory {
  static Map<String, Logger> _loggerCache;
  static LoggerFactory _instance;
  static LoggerBuilder _builder;
  
  /**
   * Assign a builder to this factory. 
   * 
   * A builder is a function that takes a name and returns a logger
   */
  static set builder(LoggerBuilder builder) {
    _builder = builder;
  }
  
  LoggerFactory._internal();
  
  static Logger getLogger(String name) {
    if(_builder == null) {
      // no builder exists, default to LoggerImpl
      _builder = (n) => new LoggerImpl(n);
    }
    if(_loggerCache == null) {
      _loggerCache = new Map<String, Logger>();
    }
    if(!_loggerCache.containsKey(name)) {
      _loggerCache[name] = _builder(name);
    }
    
    Logger logger = _loggerCache[name];
    Expect.isNotNull(logger);
    return logger;
  }
}

/**
 * Function invoked by the LoggerFactory that creates the actual logger for a given name
 */
typedef Logger LoggerBuilder(String loggerName);