// Copyright (c) 2012 Qalqo, all rights reserved.  
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

/**
 * Appender that logs to the console
 */
class ConsoleAppender implements Appender {
  void doAppend(String message) {
    print(message);      
  }
}
