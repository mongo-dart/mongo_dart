typedef IPersistent FactoryMethod();
class PropertySchema {
  String name;
  String type;
  bool collection;
  bool internalObject;
  bool externalRef;
  PropertySchema(this.name,this.type,[this.collection = false, this.internalObject = false, this.externalRef = false]);
  String toString() => "PropertySchema(${this.name},${this.type},this.collection = ${this.collection}, this.internalObject = ${this.internalObject}, this.externalRef = ${this.externalRef})";
}
class ClassSchema{
  static final SimpleProperty = 0;
  static final InternalObject = 1;
  static final ExternalObject = 2;
  String className;
  FactoryMethod factoryMethod;
  Map<String,PropertySchema> properties;
  ClassSchema(this.className,this.factoryMethod) {
    properties = new Map<String,PropertySchema>();
  }
  addProperty(PropertySchema propertySchema) {
    properties[propertySchema.name] = propertySchema;    
  }
}
