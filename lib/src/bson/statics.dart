part of bson;
class Statics{
  static Stopwatch _stopwatch;  
  static startStopwatch() => _stopwatch = new Stopwatch()..start();
  static stopStopwatch() => _stopwatch.stop();
  static Duration getElapsedTime(){
    _stopwatch.stop();
    return new Duration(milliseconds: _stopwatch.elapsedInMs());        
  }
  static int _current_increment = 0;
  static int get nextIncrement
  {
    return _current_increment++;
  }   
  static int _requestId;
  static int get nextRequestId
  {
    if (_requestId === null)
    {
      _requestId = 1;
    } 
    return ++_requestId;
  }   

  static List<int> _maxBits;  
  static int MaxBits(int bits){    
    int res;
    if (_maxBits === null){
      _maxBits = new List<int>(65);
      _maxBits[0] = 0;
      for (var i = 1; i < 65; i++) {
        _maxBits[i]=(2 << i-1);
      }
    }
    return _maxBits[bits];
  }  
  static final int MachineId = (new Random().nextDouble() * 0xFFFFFF).floor().toInt();
  static final int Pid = (new Random().nextDouble() * 0xFFFF).floor().toInt();
  static final Map<String,List<int>> keys = new Map<String,List<int>>();  
  static getKeyUtf8(String key){
    if (!keys.containsKey(key)){      
      keys[key] = encodeUtf8(key);    
    }
    return keys[key];
  }
}
