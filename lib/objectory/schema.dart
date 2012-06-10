typedef PersistentObject FactoryMethod();
class PropertySchema {
  String name;
  String type;
  bool collection;
  bool internalObject;
  bool externalRef;
  bool containExternalRef;
  PropertySchema(this.name,this.type,[this.collection = false, this.internalObject = false, this.externalRef = false, this.containExternalRef = false]);
  String toString() => "PropertySchema(${this.name},${this.type},this.collection = ${this.collection}, this.internalObject = ${this.internalObject}, this.externalRef = ${this.externalRef} this.containExternalRef = ${this.containExternalRef})";
}
class ClassSchema{
  String className;
  FactoryMethod factoryMethod;
  bool preserveFieldsOrder;
  Map<String,PropertySchema> properties;
  ClassSchema(this.className,this.factoryMethod, [this.preserveFieldsOrder = false]) {
    properties = new LinkedHashMap<String,PropertySchema>();
  }
  addProperty(PropertySchema propertySchema) {
    properties[propertySchema.name] = propertySchema;    
  }
}
