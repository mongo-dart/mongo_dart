class LoggerFactory {
  static Map<String, Logger> _loggerCache;
  static LoggerFactory _instance;
  static var _builder;
  
  /**
   * Assign a builder to this factory. 
   * 
   * A builder is a function that takes a name and returns a logger
   */
  static set builder(Logger builder(String)) {
    _builder = builder;
  }
  static get builder() {
    return _builder;
  }  
  LoggerFactory._internal();
  
  static Logger getLogger(String name) {
    if(_builder == null) {
      // no builder exists, default to LoggerImpl
      _builder = (name) => new LoggerImpl(name);
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
