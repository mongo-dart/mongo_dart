/**
 * Implemented by classes that performs the actual logging
 */
interface Appender {
  /**
   * Log a message. The message can be any type, this is done to facilitate a wide range of logging mecahnicms.
   */
  void doAppend(Dynamic logMessage);
}