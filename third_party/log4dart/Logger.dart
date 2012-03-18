interface Logger {
  /**
   * Log a message at the DEBUG level.
   */
  debug(String message);
  
  /**
   * Log a message at the DEBUG level according to the specified format and argument.
   */
  debugFormat(String format, List args);
  
  /**
   * Log a message at the ERROR level.
   */
  error(String message);
  
  /**
   * Log a message at the ERROR level according to the specified format and argument.
   */
  errorFormat(String format, List args);
  
  /**
   * Log a message at the INFO level.
   */
  info(String message);
  
  /**
   * Log a message at the INFO level according to the specified format and argument.
   */
  infoFormat(String format, List args);
  
  /**
   * Log a message at the WARN level.
   */
  warn(String message);
  
  /**
   * Log a message at the WARN level according to the specified format and argument.
   */
  warnFormat(String format, List args);
  
  /**
   * Is the logger instance enabled for the DEBUG level?
   */
  bool get debugEnabled();
  
  /**
   * Is the logger instance enabled for the INFO level?
   */
  bool get infoEnabled();
  
  /**
   * Is the logger instance enabled for the WARN level?
   */
  bool get warnEnabled();
  
  /**
   * Is the logger instance enabled for the ERROR level?
   */
  bool get errorEnabled();
  
  /**
   * Clear all entries in the diagnostic context.
   */
  void clearContext(); 
  
  /**
   * Return the name of this Logger instance.
   */
  String name;
  
  /**
   * Get the diagnostic context identified by the key parameter.
   */
  String getContect(String key);
  
  /**
   * Put a context value (the val parameter) as identified with the key parameter into the loggers diagnostic context map.
   */
  void putContext(String key, String val);
  
  /**
   * Remove the the diagnostic context identified by the key parameter.
   */
  void removeContext(String key);
}

