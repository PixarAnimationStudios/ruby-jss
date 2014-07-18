#!/usr/bin/ruby

simple_classes = [
  JSS::Building,
  JSS::Category,
  JSS::Department,
  JSS::RemovableMacAddress,
  JSS::User
]

testing_object_name = "JSSGem-testing"

#### Loop thru the simple classes
simple_classes.each do |testing_class|
  
  puts
  puts "******** Testing #{testing_class} **********"
  puts
  
  #####
  puts "Testing .all..."
  testing_class.all.each {|b| puts "...#{testing_class} #{b[:name]} has id #{b[:id]}" }
  
  puts "======================"
  
  puts "Testing .all_names(:refresh) and all_ids..."
  
  puts testing_class.all_names(:refresh).sort.join ', '
  puts
  puts testing_class.all_ids.sort.join ', '
  
  puts "======================"
  puts "Testing .map_all_ids_to(:name)..."
  
  testing_class.map_all_ids_to(:name).each{|i,n|  puts "...#{testing_class} id #{i} is named #{n}"  }
  
  puts "======================"
  
  puts "Testing .xml_list with names..."
  puts testing_class.xml_list testing_class.all
  
  puts "======================"
  
  puts "Testing .xml_list with ids..."
  puts testing_class.xml_list testing_class.all, :id
  
  puts "======================"
  
  puts "Testing init with id..."
  obj = testing_class.new :id => testing_class.all_ids.sample
  
  puts "Got #{testing_class}: #{obj.name}"
  
  puts "======================"
  
  puts "Testing init with name..."
  obj = testing_class.new :name => testing_class.all_names.sample
  
  puts "Got #{testing_class}:  #{obj.name}, id #{obj.id}"
  
  puts "======================"
  
  puts "Testing init with data..."
  obj = testing_class.new :data => JSS::API.get_rsrc("#{testing_class::RSRC_BASE}/id/#{obj.id}")[testing_class::RSRC_OBJECT_KEY]
  
  puts "Got #{testing_class}:  #{obj.name}, id #{obj.id}"
  
  puts "======================"
  
  puts "Testing .rest_xml..."
  
  # make a public wrapper
  def obj.test_xml ; rest_xml ; end
  puts obj.test_xml

  
  
  
  
  
  if testing_class.constants.include? "CREATABLE"
    puts "======================"
    puts "Class #{testing_class} is creatable, making a new one..."
    test_obj = testing_class.new :id => :new, :name => testing_object_name
    test_obj.create
  
    
    if testing_class.constants.include? "UPDATABLE"
      puts "======================"
      puts "Class #{testing_class} is Updatable, changing the name..."
      test_obj.name = testing_object_name+"2"
      test_obj.update
    end
  
    puts "======================"
    puts "Deleting newly create #{testing_class}"
    test_obj.delete
  end

end # each do testing_class

puts "Done!"
