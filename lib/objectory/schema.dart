#library("persistent_schema");
typedef Object FactoryMethod();
class PropertySchema {
  String name;
  String type;
  bool collection;
  bool embeddedObject;
  bool link;
  bool hasLinks;
  PropertySchema(this.name,this.type,[this.collection = false, this.embeddedObject = false, this.link = false, this.hasLinks = false]);
  String toString() => "PropertySchema(${this.name},${this.type},this.collection = ${this.collection}, this.embeddedObject = ${this.embeddedObject}, this.link = ${this.link} this.hasLinks = ${this.hasLinks})";
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
