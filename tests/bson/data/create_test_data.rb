require 'bson'
doc = {'_id'=>5, 'a'=>4}
message = BSON::BSON_RUBY.serialize(doc)

#message.to_a.each do | byte |
    #puts byte.to_i
#end

File.open('01.data', "wb") do |file|
   file.write(message.to_a.pack('C*'))
end

doc = {'_id'=>5, 'a'=> [2,3,5]}
message = BSON::BSON_RUBY.serialize(doc)
message.to_a.each do | byte |
    puts byte.to_i
end

File.open('02.data', "wb") do |file|
   file.write(message.to_a.pack('C*'))
end

doc = {'a'=> [15]}
message = BSON::BSON_RUBY.serialize(doc)
message.to_a.each do | byte |
    puts byte.to_i
end

File.open('03.data', "wb") do |file|
   file.write(message.to_a.pack('C*'))
end