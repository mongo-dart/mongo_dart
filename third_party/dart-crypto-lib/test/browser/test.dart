#import('dart:html');
#import('../../src/hash.dart');
#import('../../src/md5.dart');
#import('../../src/sha1.dart');

class test {
  StringBuffer logBuffer;
  test() {
  }

  void run() {
    logBuffer = new StringBuffer();
    log('start of tests');
    testHashes();
    log('end of tests');
    display(logBuffer.toString());
  }

  void display(String message) {
    // the HTML library defines a global "document" variable
    document.query('#status').innerHTML = message;
  }
  
  void log(String message) {
    logBuffer.add(message);
    logBuffer.add('\n<p>\n');
  }
  
  
  String digestToString(List<int> digest) {
    StringBuffer sb = new StringBuffer();
    int len = digest.length;
    for (int i = 0; i < len; i++) {
      String hex = digest[i].toRadixString(16).toLowerCase();
      if (hex.length == 1) sb.add('0');
      sb.add(hex);
    }
    return sb.toString();
  }

  void checkHash(Hash hash, String input, String expected) {
    hash.reset();
    hash.updateString(input);
    String out = digestToString(hash.digest());
    if (out != expected) {
      log("'${input}' -> '$out' != '$expected'");
    }
  }

  // Test md5 digests from http://en.wikipedia.org/wiki/MD5
  void testMd5() {
    Hash hash = new Md5();
    checkHash(hash, '', 'd41d8cd98f00b204e9800998ecf8427e');
    checkHash(hash, 'The quick brown fox jumps over the lazy dog', '9e107d9d372bb6826bd81d3542a419d6');
    checkHash(hash, 'The quick brown fox jumps over the lazy dog.', 'e4d909c290d0fb1ca068ffaddf22cbd0');
  }

  // Test Sha1 digests from http://en.wikipedia.org/wiki/SHA-1
  void testSha1() {
    Hash hash = new Sha1();
    checkHash(hash, '', 'da39a3ee5e6b4b0d3255bfef95601890afd80709');
    checkHash(hash, 'The quick brown fox jumps over the lazy dog', '2fd4e1c67a2d28fced849ee1bb76e7391b93eb12');
    checkHash(hash, 'The quick brown fox jumps over the lazy cog', 'de9f2c7fd25e1b3afad3e85a0bd17d9b100db4b3');
  }

  void testHashes() {
    testMd5();
    testSha1();
  }
}

void main() {
  new test().run();
}
