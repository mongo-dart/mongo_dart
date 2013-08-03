part of mongo_dart;
class _MessageHeader {
    int   messageLength; 
    int   requestID;     
    int   responseTo;    
    int   opCode;
    String toString(){
      return "MessageHeader(messageLength $messageLength,requestID $requestID,responseTo $responseTo,opCode $opCode)";
    }
}