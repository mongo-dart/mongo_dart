class ContextLogTest {
  final Logger _logger;
  
  ContextLogTest(): _logger = LoggerFactory.getLogger("ContextLogTest") {
    _logger.putContext("context", "context-message");
    try {
      _logger.debug("started tracking context");
      
      // the logger in simple log test inherits the context setup above;
      new SimpleLogTest();
    } finally {
      _logger.removeContext("context");
    }
  }
}
