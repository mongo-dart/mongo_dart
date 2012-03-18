/**
 * Appender that logs to the console
 */
class ConsoleAppender implements Appender {
  void doAppend(String message) {
    print(message);      
  }
}
