class SimpleLogTest {
  final Logger _logger;
  
  SimpleLogTest(): _logger = LoggerFactory.getLogger("SimpleLogTest") {
    _logger.debug("a debug message");
    if(_logger.infoEnabled) _logger.info("a info message");
    _logger.warn("a warning");
    _logger.error("a error");
  }
}
