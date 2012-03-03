require 'mongo'

db = Mongo::Connection.new.db("test")
print db.command({ping:1})