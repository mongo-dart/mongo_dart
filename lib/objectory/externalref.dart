class ExternalRef {
  ObjectId id;
  RootPersistentObject ref;
  ExternalRef(this.id, [this.ref]);
  toString() => "ExtenralRef(${this.id}, ${this.ref})";
}
