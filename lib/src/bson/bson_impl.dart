part of bson;
class BSON {

  static const BSON_INT32_MAX = 0x7FFFFFFF;
  static const BSON_INT32_MIN = -0x80000000;

  //static const BSON_INT64_MAX = Math.pow(2, 63) - 1;
  //static const BSON_INT64_MIN = -Math.pow(2, 63);

  // JS MAX PRECISE VALUES
  static const JS_INT_MAX = 0x20000000000000;  // Any integer up to 2^53 can be precisely represented by a double.
  static const JS_INT_MIN = -0x20000000000000;  // Any integer down to -2^53 can be precisely represented by a double.

  // Internal long versions
  static const JS_INT_MAX_LONG = 0x20000000000000;  // Any integer up to 2^53 can be precisely represented by a double.
  static const JS_INT_MIN_LONG = -0x20000000000000;  // Any integer down to -2^53 can be precisely represented by a double.

  /**
   * Number BSON Type
   *
   * @classconstant BSON_DATA_NUMBER
   **/
  static const BSON_DATA_NUMBER = 1;
  /**
   * String BSON Type
   *
   * @classconstant BSON_DATA_STRING
   **/
  static const BSON_DATA_STRING = 2;
  /**
   * Object BSON Type
   *
   * @classconstant BSON_DATA_OBJECT
   **/
  static const BSON_DATA_OBJECT = 3;
  /**
   * Array BSON Type
   *
   * @classconstant BSON_DATA_ARRAY
   **/
  static const BSON_DATA_ARRAY = 4;
  /**
   * BsonBinary BSON Type
   *
   * @classconstant BSON_DATA_BINARY
   **/
  static const BSON_DATA_BINARY = 5;
  /**
   * ObjectID BSON Type
   *
   * @classconstant BSON_DATA_OID
   **/
  static const BSON_DATA_OID = 7;
  /**
   * Boolean BSON Type
   *
   * @classconstant BSON_DATA_BOOLEAN
   **/
  static const BSON_DATA_BOOLEAN = 8;
  /**
   * Date BSON Type
   *
   * @classconstant BSON_DATA_DATE
   **/
  static const BSON_DATA_DATE = 9;
  /**
   * null BSON Type
   *
   * @classconstant BSON_DATA_NULL
   **/
  static const BSON_DATA_NULL = 10;
  /**
   * RegExp BSON Type
   *
   * @classconstant BSON_DATA_REGEXP
   **/
  static const BSON_DATA_REGEXP = 11;
  /**
   * Code BSON Type
   *
   * @classconstant BSON_DATA_DBPOINTER
   **/
  static const BSON_DATA_DBPOINTER = 12;

  /**
   * Code BSON Type
   *
   * @classconstant BSON_DATA_CODE
   **/
  static const BSON_DATA_CODE = 13;
  /**
   * Symbol BSON Type
   *
   * @classconstant BSON_DATA_SYMBOL
   **/
  static const BSON_DATA_SYMBOL = 14;
  /**
   * Code with Scope BSON Type
   *
   * @classconstant BSON_DATA_CODE_W_SCOPE
   **/
  static const BSON_DATA_CODE_W_SCOPE = 15;
  /**
   * 32 bit Integer BSON Type
   *
   * @classconstant BSON_DATA_INT
   **/
  static const BSON_DATA_INT = 16;
  /**
   * Timestamp BSON Type
   *
   * @classconstant BSON_DATA_TIMESTAMP
   **/
  static const BSON_DATA_TIMESTAMP = 17;
  /**
   * Long BSON Type
   *
   * @classconstant BSON_DATA_LONG
   **/
  static const BSON_DATA_LONG = 18;
  /**
   * MinKey BSON Type
   *
   * @classconstant BSON_DATA_MIN_KEY
   **/
  static const BSON_DATA_MIN_KEY = 0xff;
  /**
   * MaxKey BSON Type
   *
   * @classconstant BSON_DATA_MAX_KEY
   **/
  static const BSON_DATA_MAX_KEY = 0x7f;

  /**
   * BsonBinary Default Type
   *
   * @classconstant BSON_BINARY_SUBTYPE_DEFAULT
   **/
  static const BSON_BINARY_SUBTYPE_DEFAULT = 0;
  /**
   * BsonBinary Function Type
   *
   * @classconstant BSON_BINARY_SUBTYPE_FUNCTION
   **/
  static const BSON_BINARY_SUBTYPE_FUNCTION = 1;
  /**
   * BsonBinary Byte Array Type
   *
   * @classconstant BSON_BINARY_SUBTYPE_BYTE_ARRAY
   **/
  static const BSON_BINARY_SUBTYPE_BYTE_ARRAY = 2;
  /**
   * BsonBinary UUID Type
   *
   * @classconstant BSON_BINARY_SUBTYPE_UUID
   **/
  static const BSON_BINARY_SUBTYPE_UUID = 3;
  /**
   * BsonBinary MD5 Type
   *
   * @classconstant BSON_BINARY_SUBTYPE_MD5
   **/
  static const BSON_BINARY_SUBTYPE_MD5 = 4;
  /**
   * BsonBinary User Defined Type
   *
   * @classconstant BSON_BINARY_SUBTYPE_USER_DEFINED
   **/
  static const BSON_BINARY_SUBTYPE_USER_DEFINED = 128;


  BsonBinary serialize(var object, [int offset = 0]) {
    if (!((object is Map) || (object is List))){
      throw new Exception("Invalid value for BSON serialize: $object");
    }
    BsonObject bsonObject = bsonObjectFrom(object);
    BsonBinary buffer = new BsonBinary(bsonObject.byteLength()+offset);
    buffer.offset = offset;
    bsonObjectFrom(object).packValue(buffer);
    return buffer;
  }
  deserialize(BsonBinary buffer){
    if(buffer.byteList.length < 5){
      throw new Exception("corrupt bson message < 5 bytes long");
    }
    var bsonMap = new BsonMap(null);
    bsonMap.unpackValue(buffer);
    return bsonMap.value;
  }
}