part of mongo;

class MapProxy<K,V> implements Map<K,V>{
  LinkedHashMap map;
  Queue keys;
  MapProxy(): map = new LinkedHashMap();
  bool containsValue(V value)=>map.containsValue(value);

  bool containsKey(K key)=>map.containsKey(key);

  V operator [](K key)=>map[key];

  void operator []=(K key, V value){
   map[key]=value;
  }

  V putIfAbsent(K key, V ifAbsent())=>map.putIfAbsent(key, ifAbsent);

  V remove(K key)=>map.remove(key);

  void clear()=>map.clear();

  void forEach(void f(K key, V value))=>map.forEach(f);

  Collection<K> getKeys() => map.keys;

  Collection<V> getValues() => map.values;

  int get length => map.length;

  bool get isEmpty => map.isEmpty;
}
