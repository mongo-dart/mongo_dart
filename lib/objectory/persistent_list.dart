class PersistentList<T> implements List<T>{
  IPersistent parent;
  String pathToMe;  
  final List<T> _list;
  
  PersistentList(this._list);
  
  void setDirty(String propertyName) {
    parent.setDirty(pathToMe);    
  }
  
  void operator[]=(int index, T value){
    _list[index] = value;
    if (value is InnerPersistentObject) {
      value.parent = parent;
      value.pathToMe = pathToMe;
    }
    setDirty(null);
  }
  
  T operator[](int index) {
    var result = _list[index];
    if (result is !IPersistent) {
      PropertySchema propertySchema = objectory.getSchema(parent.type).properties[pathToMe];
      if (propertySchema.internalObject) {
        result = objectory.map2Object(propertySchema.type, result);
      }          
    }
    return result;
  }
  bool isEmpty() => _list.isEmpty();
  
  void forEach(void f(element)) => _list.forEach(f);
  
  Collection map(f(T element)) => _list.map(f);
  
  Collection<T> filter(bool f(T element)) => _list.filter(f);
  
  bool every(bool f(T element)) => _list.every(f);
  
  bool some(bool f(T element)) => _list.some(f);
  
  Iterator<T> iterator() => _list.iterator();
  
  int indexOf(T element, [int start = 0]) => _list.indexOf(element, start);
  
  int lastIndexOf(T element, [int start = 0]) => _list.lastIndexOf(element, start);
  
  int get length() => _list.length;
  
  List getRange(int start, int length) => _list.getRange(start, length);
  
  void add(T element){
    _list.add(element);
    setDirty(null);
  }
  
  void remove(T element){
    if (_list.indexOf(element) == -1) return;
    _list.removeRange(_list.indexOf(element), 1);
    setDirty(null);
  }
  
  void addAll(Collection<T> elements){
    _list.addAll(elements);
    setDirty(null);    
  }
  
  void clear(){
    Collection<T> c = _list;
    _list.clear();
    setDirty(null);
  }
  
  T removeLast(){
    T item = _list.last();    
    _list.removeLast();
    setDirty(null);
    return item;
  }
  
  T last() => _list.last();
  
  void sort(int compare(a, b)) => _list.sort(compare);
  
  void insertRange(int start, int length, [T initialValue = null]){
    _list.insertRange(start, length, initialValue);
    setDirty(null);
  }
  
  void addLast(T value) => _list.addLast(value);
  
  void removeRange(int start, int length){    
    _list.removeRange(start, length);    
    setDirty(null);
  }
  
  void setRange(int start, int length, List<T> from, [int startFrom = 0]){    
    _list.setRange(start, length, from, startFrom);    
    setDirty(null);
  } 

}