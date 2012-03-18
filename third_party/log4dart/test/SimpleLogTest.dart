class SimpleLogTest {
  Logger logger;
  
  SimpleLogTest(): logger = LoggerFactory.getLogger("SimpleLogTest") {
    logger.debug("a debug message");
    if(logger.infoEnabled) logger.info("a info message");
    logger.warn("a warning");
    logger.error("a error");
  }
}
