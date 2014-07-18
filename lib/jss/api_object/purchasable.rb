module JSS


### A mix-in module for handling purchasing data for objects in the JSS.
###
### The JSS objects that have purchasing data all have basically the same data,
### a simple hash with these keys:
### 
###   :applecare_id => String,
###   :is_leased => Boolean,
###   :is_purchased => Boolean,
###   :lease_expires => DateTime,
###   :life_expectancy => Integer,
###   :po_date => DateTime,
###   :po_number => String,
###   :purchase_price => Float,
###   :purchasing_account => String
###   :purchasing_contact => String,
###   :vendor => String,
###   :warranty_expires => DateTime
###
### Additionally some objects have these keys
###   :os_applecare_id => String,
###   :os_maintenance_expires => DateTime
###
### 
### These items become direct attributes of objects where this module is mixed-in.
###
### 


  
  #####################################
  ### Module Variables
  #####################################

  #####################################
  ### Module Methods
  #####################################
  
  #####################################
  ### Sub-Modules
  #####################################
  
  module Purchasable
    
    #####################################
    ###  Constants
    #####################################
    
    PURCHASABLE = true
    
    SUBSET_PURCH = "Purchasing"
    
    #####################################
    ###  Variables
    #####################################
    
    #####################################
    ###  Attribtues
    #####################################
    
    attr_reader :applecare_id
    
    attr_reader :is_leased
    alias leased? is_leased
    
    attr_reader :lease_expires
    
    attr_reader :is_purchased
    alias purchased? is_purchased
    
    attr_reader :purchase_price
    
    attr_reader :life_expectancy
    
    attr_reader :po_number
    
    attr_reader :po_date
    
    attr_reader :purchasing_account
    
    attr_reader :purchasing_contact
    
    attr_reader :vendor
    
    attr_reader :warranty_expires
    
    attr_reader :os_applecare_id
    
    attr_reader :os_maintenance_expires
    
    
    
    #####################################
    ###  Mixed-in Instance Methods
    #####################################
    
    
    
    ###
    ### Call this during initialization of 
    ### objects that have a Purchasing subset
    ### and the purchasing attribute will be populated
    ### from @init_data
    ###
    def parse_purchasing
      return unless @init_data[:purchasing] 
      
      @purchasing = @init_data[:purchasing] 
      
      @lease_expires = JSS.parse_datetime  @purchasing[:lease_expires_epoch]
      @po_date = JSS.parse_datetime  @purchasing[:po_date_epoch]
      @warranty_expires = JSS.parse_datetime  @purchasing[:warranty_expires_epoch]
      @os_maintenance_expires = JSS.parse_datetime  @purchasing[:os_maintenance_expires_epoch]
      
      @applecare_id = @purchasing[:applecare_id]
      @is_leased = @purchasing[:is_leased]
      @is_purchased = @purchasing[:is_purchased]
      @life_expectancy = @purchasing[:life_expectancy]
      @po_number = @purchasing[:po_number]
      @purchase_price = @purchasing[:purchase_price]
      @purchasing_account = @purchasing[:purchasing_account]
      @purchasing_contact = @purchasing[:purchasing_contact]
      @vendor = @purchasing[:vendor]
      @os_applecare_id = @purchasing[:os_applecare_id]
      
      
    end
    
    def applecare_id= (new_val)
      return nil if @applecare_id == new_val
      @applecare_id = new_val
      @need_to_update = true
    end
    
    def is_leased= (new_val)
      return nil if @is_leased == new_val
      @is_leased = new_val
      @need_to_update = true
    end
    
    def lease_expires= (date)
      return nil if @lease_expires == date
      @lease_expires = JSS.parse_datetime date
      @need_to_update = true
    end
    
    def is_purchased= (new_val)
      return nil if @is_purchased == new_val
      @is_purchased = new_val
      @need_to_update = true
    end
    
    def purchase_price= (new_val)
      return nil if @purchase_price == new_val
      @purchase_price = new_val
      @need_to_update = true
    end
    
    def life_expectancy= (new_val)
      return nil if @life_expectancy == new_val
      @life_expectancy = new_val
      @need_to_update = true
    end
    
    def po_number= (new_val)
      return nil if @po_number == new_val
      @po_number = new_val
      @need_to_update = true
    end
    
    def po_date= (date)
      return nil if @po_date == date
      @po_date = JSS.parse_datetime date
      @need_to_update = true
    end
    
    def purchasing_account= (new_val)
      return nil if @purchasing_account == new_val
      @purchasing_account = new_val
      @need_to_update = true
    end
    
    def purchasing_contact= (new_val)
      return nil if @purchasing_contact == new_val
      @purchasing_contact = new_val
      @need_to_update = true
    end
    
    def vendor= (new_val)
      return nil if @vendor == new_val
      @vendor = new_val
      @need_to_update = true
    end
    
    def warranty_expires= (date)
      return nil if @warranty_expires == date
      @warranty_expires = JSS.parse_datetime date
      @need_to_update = true
    end
    
    
    def os_applecare_id= (new_val)
      return nil if @os_applecare_id == new_val
      @os_applecare_id = new_val
      @need_to_update = true
    end
    
    def os_maintenance_expires= (date)
      return nil if @os_maintenance_expires == date
      @os_maintenance_expires = JSS.parse_datetime date
      @need_to_update = true
    end
    
    ###
    ### Return a REXML <purchasing> element to be
    ### included in the rest_xml of 
    ### objects that have a Purchasing subset
    ###
    def purchasing_xml
      purch = REXML::Element.new('purchasing')

      purch.add_element('applecare_id').text = @applecare_id
      purch.add_element('is_leased').text = @is_leased
      purch.add_element('is_purchased').text = @is_purchased
      purch.add_element('lease_expires').text = @lease_expires.to_jss_xml_date if @lease_expires
      purch.add_element('life_expectancy').text = @life_expectancy
      purch.add_element('po_date').text = @po_date.to_jss_xml_date if @po_date
      purch.add_element('po_number').text = @po_number
      purch.add_element('purchase_price').text = @purchase_price
      purch.add_element('purchasing_account').text = @purchasing_account
      purch.add_element('purchasing_contact').text = @purchasing_contact
      purch.add_element('vendor').text = @vendor
      purch.add_element('warranty_expires').text = @warranty_expires.to_jss_xml_date if @warranty_expires
      
      purch.add_element('os_applecare_id').text = @os_applecare_id if @os_applecare_id
      purch.add_element('os_maintenance_expires').text = @os_maintenance_expires.to_jss_xml_date if @os_maintenance_expires
      return purch
    end
    
  end # module Purchasable
end # module JSS
