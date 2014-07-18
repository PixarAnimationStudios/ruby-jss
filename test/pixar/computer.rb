testing_class = JSS::Computer

test_computer = "kimchi"

puts
puts "******** Testing #{testing_class} **********"
puts

##### Class Methods
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


### Initialization

puts "======================"
puts "Testing init with id..."
obj = testing_class.new :id => testing_class.all_ids.sample

puts "Got #{testing_class}: #{obj.name}"
puts "======================"

puts "Testing init with name..."
obj = testing_class.new :name => testing_class.all_names.sample

puts "Got #{testing_class}:  #{obj.name}, id #{obj.id}"

puts "======================"
puts "Testing init with data for computer #{test_computer}..."
obj = testing_class.new :data => JSS::API.get_rsrc("#{testing_class::RSRC_BASE}/name/#{test_computer}")[testing_class::RSRC_OBJECT_KEY]
puts "Got #{testing_class}:  #{obj.name}, id #{obj.id}"

### Instance Methods
puts "======================"
puts "Testing .rest_xml..."

# make a public wrapper
def obj.test_xml ; rest_xml ; end
puts obj.test_xml

puts "======================"
puts "Testing getter attributes..."
# getting attributes
puts "   alt_mac_address => #{obj.alt_mac_address}"
puts "   asset_tag => #{obj.asset_tag}"
puts "   barcode_1 => #{obj.barcode_1}"
puts "   barcode_2 => #{obj.barcode_2}"
puts "   distribution_point => #{obj.distribution_point}"
puts "   initial_entry_date => #{obj.initial_entry_date}"
puts "   ip_address => #{obj.ip_address}"
puts "   jamf_version => #{obj.jamf_version}"
puts "   last_contact_time => #{obj.last_contact_time}"
puts "   mac_address => #{obj.mac_address}"
puts "   managed => #{obj.managed}"
puts "   management_username => #{obj.management_username}"
puts "   mdm_capable => #{obj.mdm_capable}"
puts "   netboot_server => #{obj.netboot_server}"
puts "   platform => #{obj.platform}"
puts "   report_date => #{obj.report_date}"
puts "   serial_number => #{obj.serial_number}"
puts "   site => #{obj.site}"
puts "   sus => #{obj.sus}"
puts "   udid => #{obj.udid}"
puts "   configuration_profiles => #{obj.configuration_profiles}"
puts "   extension_attributes => #{obj.extension_attributes}"
puts "   groups_accounts => #{obj.groups_accounts}"
puts "   hardware => #{obj.hardware}"
puts "   peripherals => #{obj.peripherals}"
puts "   software => #{obj.software}"


# locatable attributes....
puts "======================"
puts "Testing locatable getter attributes..."
puts "   building => #{obj.building}"
puts "   department => #{obj.department}"
puts "   email_address => #{obj.email_address}"
puts "   phone => #{obj.phone}"
puts "   position => #{obj.position}"
puts "   real_name => #{obj.real_name}"
puts "   room => #{obj.room}"
puts "   username => #{obj.username}"
    
# purchasing  attributes....
puts "======================"
puts "Testing purchasable attributes..."
puts "   applecare_id => #{obj.applecare_id}"
puts "   is_leased => #{obj.is_leased}"
puts "   lease_expires => #{obj.lease_expires}"
puts "   is_purchased => #{obj.is_purchased}"
puts "   purchase_price => #{obj.purchase_price}"
puts "   life_expectancy => #{obj.life_expectancy}"
puts "   po_number => #{obj.po_number}"
puts "   po_date => #{obj.po_date}"
puts "   purchasing_account => #{obj.purchasing_account}"
puts "   purchasing_contact => #{obj.purchasing_contact}"
puts "   vendor => #{obj.vendor}"
puts "   warranty_expires => #{obj.warranty_expires}"
puts "   os_applecare_id => #{obj.os_applecare_id}"
puts "   os_maintenance_expires => #{obj.os_maintenance_expires}"
    
    
# getter methods
puts "======================"
puts "Testing getter methods..."
puts "   arch => #{obj.arch}"
puts "   available_ram_slots => #{obj.available_ram_slots}"
puts "   battery_capacity => #{obj.battery_capacity}"
puts "   boot_rom => #{obj.boot_rom}"
puts "   bus_speed => #{obj.bus_speed}"
puts "   cache_size => #{obj.cache_size}"
puts "   cores => #{obj.cores}"
puts "   make => #{obj.make}"
puts "   model_id => #{obj.model_id}"
puts "   model => #{obj.model}"
puts "   nic_speed => #{obj.nic_speed}"
puts "   optical_drive => #{obj.optical_drive}"
puts "   os_build => #{obj.os_build}"
puts "   os_name => #{obj.os_name}"
puts "   os_version => #{obj.os_version}"
puts "   proc_arch => #{obj.proc_arch}"
puts "   proc_speed => #{obj.proc_speed}"
puts "   proc_type => #{obj.proc_type}"
puts "   ram => #{obj.ram}"
puts "   smc_version => #{obj.smc_version}"
puts "   jss_groups =>"
obj.jss_groups.each{|g| puts "   ..#{g}"}
puts "   local_accounts => "
obj.local_accounts.each{|a| 
  puts "     #{a[:name]} => "
  a.each{ |k,v| puts "     ..#{k} => #{v}"}
}

# new values

# getter methods
puts "======================"
puts "Testing setter methods..."

new_asset_tag = "asset"
new_barcode_1 = "barcode-one"
new_barcode_2 = "narcode=two"
new_ip_address = "10.0.0.128"
new_udid = "1234567890"
new_mac_address = "aa:aa:aa:aa:aa:aa"
new_alt_mac_address = "ee:ee:ee:ee:ee:ee"

new_building = "Soho"
new_department = "Ctoons"
new_email_address = "chrisltest@pixar.com"
new_phone = "x3369"
new_position = "peeleur"
new_real_name = "ChrisLTessst"
new_room = "MyRoom"
new_username = "chrisltestttt"

new_applecare_id = "chrisltestttt@pixar.com"
new_is_leased = true
new_lease_expires = "2001-02-15"
new_is_purchased = false
new_purchase_price = 155.22
new_life_expectancy = 15
new_po_number = "123-po-456"
new_po_date = '2001-01-04'
new_purchasing_account = "0100"
new_purchasing_contact = "generalfaz@pixar.com"
new_vendor = "happy hound"
new_warranty_expires = "2001-2-20"
new_os_applecare_id = "chrisltesttrr@pixar.com"
new_os_maintenance_expires = "2019-03-03"


# Setting attributes....
obj.asset_tag = new_asset_tag
obj.barcode_1 = new_barcode_1
obj.barcode_2 = new_barcode_2
obj.ip_address = new_ip_address
obj.udid = new_udid
obj.mac_address = new_mac_address
obj.alt_mac_address = new_alt_mac_address

# locatable attributes.... 
obj.building = new_building
obj.department = new_department
obj.email_address = new_email_address
obj.phone = new_phone
obj.position = new_position
obj.real_name = new_real_name
obj.room = new_room
obj.username = new_username


# purchasing  attributes....
obj.applecare_id = new_applecare_id
obj.is_leased = new_is_leased
obj.lease_expires = new_lease_expires
obj.is_purchased = new_is_purchased
obj.purchase_price = new_purchase_price
obj.life_expectancy = new_life_expectancy
obj.po_number = new_po_number
obj.po_date = new_po_date
obj.purchasing_account = new_purchasing_account
obj.purchasing_contact = new_purchasing_contact
obj.vendor = new_vendor
obj.warranty_expires = new_warranty_expires
obj.os_applecare_id = new_os_applecare_id
obj.os_maintenance_expires = new_os_maintenance_expires

# Saving changes
# getter methods
puts "======================"
puts "Testing update/save..."
obj.save

# make un/managed
# getter methods
puts "======================"
puts "Testing making unmanaged"
obj.make_unmanaged
obj.save

# mdm_commands