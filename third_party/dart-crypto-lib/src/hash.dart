// Copyright 2011 The Closure Library Authors. All Rights Reserved.
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

#library('hash');

/**
 * @fileoverview Abstract cryptographic hash interface.
 *
 * See goog.crypt.Sha1 and goog.crypt.Md5 for sample implementations.
 *
 */


/**
 * Create a cryptographic hash instance.
 *
 * @constructor
 */
interface Hash {
 
/**
 * Resets the internal accumulator.
 */
  void reset();


/**
 * Adds a byte array (array with values in [0-255] range) to the internal accumulator.
 *
 * @param {List<number>} bytes Data used for the update.
 * @param {number=} opt_length Number of bytes to use.
 */
  void update(List<int> bytes, [int opt_length]);
  
  /**
   * Adds a string (might
   * only contain 8-bit, i.e., Latin1 characters) to the internal accumulator.
   *
   * @param {String} bytes Data used for the update.
   * @param {number=} opt_length Number of bytes to use.
   */
  void updateString(String bytes, [int opt_length]);

/**
 * @return {Array.<number>} The finalized hash computed
 *     from the internal accumulator.
 */
  List<int> digest();
}
