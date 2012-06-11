class _ValueConverter{
  BasePersistentObject parent;
  String pathToMe;
  
  _ValueConverter(this.parent,this.pathToMe);
  
   convertValue(value) {
    var result;
    PropertySchema propertySchema = objectory.getSchema(parent.type).properties[pathToMe];
    if (propertySchema.embeddedObject) {
      if (value is PersistentObject) {
        result = value;
      } else {
        result = objectory.map2Object(propertySchema.type, value);
      }          
    }
    else if (propertySchema.hasLinks) {      
      if (value !== null) {
        result = objectory.findInCache(value);
      }
      if (result === null) {
        throw "Object $value of class ${propertySchema.type} has not been fetched from objectory yet";
      }
    }
    else {
      throw "Wrong property schema $propertySchema";
    }
    return result;
  }
}
class PersistentIterator<T> implements Iterator<T> {
  Iterator _it;
  _ValueConverter valueConverter;  
  PersistentIterator(this._it, this.valueConverter);  
  T next() => valueConverter.convertValue(_it.next());
  bool hasNext() => _it.hasNext();
}

class PersistentList<T> implements List<T>{
  BasePersistentObject parent;
  String pathToMe;  
  final List _list;
  List get internalList() => _list;
  _ValueConverter _valueConverter;
  PersistentList(this._list,[this.parent, this.pathToMe]);
  
  toString() => "PersistentList($_list)";
  
  void setDirty(String propertyName) {
    parent.setDirty(pathToMe);    
  }
  
  _ValueConverter get valueConverter(){
    if (_valueConverter === null) {
      _valueConverter = new _ValueConverter(parent,pathToMe);
    }
    return _valueConverter;
  }  
  
  internValue(T value) {  
    if (value is EmbeddedPersistentObject) {
      value.parent = parent;
      value.pathToMe = pathToMe;
      return value.map;
    }
    if (value is RootPersistentObject) {
      return value.id;
    }
    return value;
  }
    
  void operator[]=(int index, T value){
    _list[index] = internValue(value);
    setDirty(null);
  }
  
  T operator[](int index) {
    return valueConverter.convertValue(_list[index]);
  }  
  bool isEmpty() => _list.isEmpty();
  
  void forEach(void f(element)) => _list.forEach(f);
  
  Collection map(f(T element)) => _list.map(f);
  
  Collection<T> filter(bool f(T element)) => _list.filter(f);
  
  bool every(bool f(T element)) => _list.every(f);
  
  bool some(bool f(T element)) => _list.some(f);
  
  Iterator<T> iterator() => new PersistentIterator(_list.iterator(),valueConverter);
  
  int indexOf(T element, [int start]) => _list.indexOf(element, start);
  
  int lastIndexOf(T element, [int start]) => _list.lastIndexOf(element, start);
  
  int get length() => _list.length;
  
  List getRange(int start, int length) => _list.getRange(start, length);
  
  void add(T element){
    _list.add(internValue(element));
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
  
  void insertRange(int start, int length, [T initialValue]){
    _list.insertRange(start, length, initialValue);
    setDirty(null);
  }
  
  void addLast(T value) => _list.addLast(value);
  
  void removeRange(int start, int length){    
    _list.removeRange(start, length);    
    setDirty(null);
  }
  
  void setRange(int start, int length, List<T> from, [int startFrom]){    
    _list.setRange(start, length, from, startFrom);    
    setDirty(null);
  } 

}