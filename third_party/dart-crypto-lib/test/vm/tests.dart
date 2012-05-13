// Copyright 2011 The Dart Crypto Library Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS-IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#library("tests");

#import("../../src/hash.dart");
#import("../../src/md5.dart");
#import("../../src/sha1.dart");

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
    print("'${input}' -> '$out' != '$expected'");
  }
}

// Test md5 digests from http://en.wikipedia.org/wiki/MD5
void testMd5() {
  Hash hash = new Md5();
  checkHash(hash, '', 'd41d8cd98f00b204e9800998ecf8427e');
  checkHash(hash,'joe:mongo:joe', 'e47ee876092b244040062d15b991ce3f');
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

void main() {
  print('Beginning tests');
  testHashes();
  print('End of tests. If you didn\'t see any errors then everything passed.');
}