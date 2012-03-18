/**
 * Appender that logs to a file
 *
 * Note to use this appender you must import dart:io
 */
class FileAppender {
  final String _path;
  
  FileAppender(this._path);

  void doAppend(String message) {
    // TODO inneficient to open file for each log message, however I am not aware of 
    // any ways to register methods to be exectued when the program shuts down
    File file = new File(_path);
    RandomAccessFile raf = file.openSync(FileMode.APPEND);
    raf.writeStringSync("$message\n");
    raf.closeSync();
 }
}
