class BSON {

  static final BSON_INT32_MAX = 0x7FFFFFFF;
  static final BSON_INT32_MIN = -0x80000000;

  //static final BSON_INT64_MAX = Math.pow(2, 63) - 1;
  //static final BSON_INT64_MIN = -Math.pow(2, 63);

  // JS MAX PRECISE VALUES
  static final JS_INT_MAX = 0x20000000000000;  // Any integer up to 2^53 can be precisely represented by a double.
  static final JS_INT_MIN = -0x20000000000000;  // Any integer down to -2^53 can be precisely represented by a double.

  // Internal long versions
  static final JS_INT_MAX_LONG = 0x20000000000000;  // Any integer up to 2^53 can be precisely represented by a double.
  static final JS_INT_MIN_LONG = -0x20000000000000;  // Any integer down to -2^53 can be precisely represented by a double.

  /**
   * Number BSON Type
   *  
   * @classconstant BSON_DATA_NUMBER
   **/
  static final BSON_DATA_NUMBER = 1;
  /**
   * String BSON Type
   *  
   * @classconstant BSON_DATA_STRING
   **/
  static final BSON_DATA_STRING = 2;
  /**
   * Object BSON Type
   *  
   * @classconstant BSON_DATA_OBJECT
   **/
  static final BSON_DATA_OBJECT = 3;
  /**
   * Array BSON Type
   *  
   * @classconstant BSON_DATA_ARRAY
   **/
  static final BSON_DATA_ARRAY = 4;
  /**
   * Binary BSON Type
   *  
   * @classconstant BSON_DATA_BINARY
   **/
  static final BSON_DATA_BINARY = 5;
  /**
   * ObjectID BSON Type
   *  
   * @classconstant BSON_DATA_OID
   **/
  static final BSON_DATA_OID = 7;
  /**
   * Boolean BSON Type
   *  
   * @classconstant BSON_DATA_BOOLEAN
   **/
  static final BSON_DATA_BOOLEAN = 8;
  /**
   * Date BSON Type
   *  
   * @classconstant BSON_DATA_DATE
   **/
  static final BSON_DATA_DATE = 9;
  /**
   * null BSON Type
   *  
   * @classconstant BSON_DATA_NULL
   **/
  static final BSON_DATA_NULL = 10;
  /**
   * RegExp BSON Type
   *  
   * @classconstant BSON_DATA_REGEXP
   **/
  static final BSON_DATA_REGEXP = 11;
  /**
   * Code BSON Type
   *  
   * @classconstant BSON_DATA_CODE
   **/
  static final BSON_DATA_CODE = 13;
  /**
   * Symbol BSON Type
   *  
   * @classconstant BSON_DATA_SYMBOL
   **/
  static final BSON_DATA_SYMBOL = 14;
  /**
   * Code with Scope BSON Type
   *  
   * @classconstant BSON_DATA_CODE_W_SCOPE
   **/
  static final BSON_DATA_CODE_W_SCOPE = 15;
  /**
   * 32 bit Integer BSON Type
   *  
   * @classconstant BSON_DATA_INT
   **/
  static final BSON_DATA_INT = 16;
  /**
   * Timestamp BSON Type
   *  
   * @classconstant BSON_DATA_TIMESTAMP
   **/
  static final BSON_DATA_TIMESTAMP = 17;
  /**
   * Long BSON Type
   *  
   * @classconstant BSON_DATA_LONG
   **/
  static final BSON_DATA_LONG = 18;
  /**
   * MinKey BSON Type
   *  
   * @classconstant BSON_DATA_MIN_KEY
   **/
  static final BSON_DATA_MIN_KEY = 0xff;
  /**
   * MaxKey BSON Type
   *  
   * @classconstant BSON_DATA_MAX_KEY
   **/
  static final BSON_DATA_MAX_KEY = 0x7f;

  /**
   * Binary Default Type
   *  
   * @classconstant BSON_BINARY_SUBTYPE_DEFAULT
   **/
  static final BSON_BINARY_SUBTYPE_DEFAULT = 0;
  /**
   * Binary Function Type
   *  
   * @classconstant BSON_BINARY_SUBTYPE_FUNCTION
   **/
  static final BSON_BINARY_SUBTYPE_FUNCTION = 1;
  /**
   * Binary Byte Array Type
   *  
   * @classconstant BSON_BINARY_SUBTYPE_BYTE_ARRAY
   **/
  static final BSON_BINARY_SUBTYPE_BYTE_ARRAY = 2;
  /**
   * Binary UUID Type
   *  
   * @classconstant BSON_BINARY_SUBTYPE_UUID
   **/
  static final BSON_BINARY_SUBTYPE_UUID = 3;
  /**
   * Binary MD5 Type
   *  
   * @classconstant BSON_BINARY_SUBTYPE_MD5
   **/
  static final BSON_BINARY_SUBTYPE_MD5 = 4;
  /**
   * Binary User Defined Type
   *  
   * @classconstant BSON_BINARY_SUBTYPE_USER_DEFINED
   **/
  static final BSON_BINARY_SUBTYPE_USER_DEFINED = 128;


  Binary serialize(var object, [int offset = 0]) {
    if (!((object is Map) || (object is List))){
      throw new Exception("Invalid value for BSON serialize: $object");
    }
    BsonObject bsonObject = bsonObjectFrom(object);    
    Binary buffer = new Binary(bsonObject.byteLength()+offset);
    buffer.offset = offset;
    bsonObjectFrom(object).packValue(buffer);
    return buffer;  
  }
  deserialize(Binary buffer){
    if(buffer.bytes.length < 5){
      throw new Exception("corrupt bson message < 5 bytes long");
    }    
    var bsonMap = new BsonMap(null);
    bsonMap.unpackValue(buffer);
    return bsonMap.value;
  }
}