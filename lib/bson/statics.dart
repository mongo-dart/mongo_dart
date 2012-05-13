class Statics{
  static Stopwatch _stopwatch;  
  static startStopwatch() => _stopwatch = new Stopwatch.start();
  static stopStopwatch() => _stopwatch.stop();
  static Duration getElapsedTime(){
    _stopwatch.stop();
    return new Duration(milliseconds: _stopwatch.elapsedInMs());        
  }
  static int _current_increment;
  static int get nextIncrement()
  {
    if (_current_increment === null)
    {
      _current_increment = 0;
    } 
    return _current_increment++;
  }   
  static int _requestId;
  static int get nextRequestId()
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
  static num _MashineId;
  static num get MachineId(){
    if (_MashineId === null){
       _MashineId = (Math.random() * 0xFFFFFFFF).floor().toInt();
    }
    return _MashineId;
  }
  static num _Pid;
  static num get Pid(){
    if (_Pid === null){
       _Pid = (Math.random() * 0xFFFF).floor().toInt();
    }
    return _Pid;
  }
  static Map<String,List<int>> _keys;
  static Map<String,List<int>> get keys(){
    if (_keys === null){
       _keys = new Map<String,List<int>>();
    }
    return _keys;
  }
  static getKeyUtf8(String key){
    if (!keys.containsKey(key)){      
      keys[key] = encodeUtf8(key);    
    }
    return keys[key];
  }
}
