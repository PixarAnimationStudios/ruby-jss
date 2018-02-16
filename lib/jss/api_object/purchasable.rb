### Copyright 2018 Pixar

###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

###
module JSS

  #####################################
  ### Module Variables
  #####################################

  #####################################
  ### Module Methods
  #####################################

  #####################################
  ### Sub-Modules
  #####################################

  ### A mix-in module for handling purchasing data for objects in the JSS.
  ###
  ### The JSS objects that have purchasing data all have basically the same data,
  ### a simple hash with these keys:
  ###
  ### -  :applecare_id => String,
  ### -  :is_leased => Boolean,
  ### -  :is_purchased => Boolean,
  ### -  :lease_expires => Time,
  ### -  :life_expectancy => Integer,
  ### -  :po_date => Time,
  ### -  :po_number => String,
  ### -  :purchase_price => Float,
  ### -  :purchasing_account => String
  ### -  :purchasing_contact => String,
  ### -  :vendor => String,
  ### -  :warranty_expires => Time
  ###
  ### These items become direct attributes of objects where this module is mixed-in.
  ###
  ###
  ### If the class also is Creatable or Updatable it must include the value of {#purchasing_xml} in its
  ### rest_xml output.
  ###
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

    ### @return [String]
    attr_reader :applecare_id

    ### @return [Boolean]
    attr_reader :is_leased

    ### @return [Time]
    attr_reader :lease_expires

    ### @return [Boolean]
    attr_reader :is_purchased

    ### @return [Float]
    attr_reader :purchase_price

    ### @return [Integer]
    attr_reader :life_expectancy

    ### @return [String]
    attr_reader :po_number

    ### @return [Time]
    attr_reader :po_date

    ### @return [String]
    attr_reader :purchasing_account

    ### @return [String]
    attr_reader :purchasing_contact

    ### @return [String]
    attr_reader :vendor

    ### @return [Time]
    attr_reader :warranty_expires


    #####################################
    ###  Mixed-in Instance Methods
    #####################################




    ### @return [void]
    def applecare_id= (new_val)
      return nil if @applecare_id == new_val
      @applecare_id = new_val
      @need_to_update = true
    end

    ### @return [void]
    def is_leased= (new_val)
      return nil if @is_leased == new_val
      @is_leased = new_val
      @need_to_update = true
    end

    ### @return [void]
    def lease_expires= (date)
      parsed_date = JSS.parse_datetime date
      return nil if @lease_expires == parsed_date
      @lease_expires = parsed_date
      @need_to_update = true
    end

    ### @return [void]
    def is_purchased= (new_val)
      return nil if @is_purchased == new_val
      @is_purchased = new_val
      @need_to_update = true
    end

    ### @return [void]
    def purchase_price= (new_val)
      return nil if @purchase_price == new_val
      @purchase_price = new_val
      @need_to_update = true
    end

    ### @return [void]
    def life_expectancy= (new_val)
      return nil if @life_expectancy == new_val
      @life_expectancy = new_val
      @need_to_update = true
    end

    ### @return [void]
    def po_number= (new_val)
      return nil if @po_number == new_val
      @po_number = new_val
      @need_to_update = true
    end

    ### @return [void]
    def po_date= (date)
      parsed_date = JSS.parse_datetime date
      return nil if @po_date == parsed_date
      @po_date = parsed_date
      @need_to_update = true
    end

    ### @return [void]
    def purchasing_account= (new_val)
      return nil if @purchasing_account == new_val
      @purchasing_account = new_val
      @need_to_update = true
    end

    ### @return [void]
    def purchasing_contact= (new_val)
      return nil if @purchasing_contact == new_val
      @purchasing_contact = new_val
      @need_to_update = true
    end

    ### @return [void]
    def vendor= (new_val)
      return nil if @vendor == new_val
      @vendor = new_val
      @need_to_update = true
    end

    ### @return [void]
    def warranty_expires= (date)
      parsed_date = JSS.parse_datetime date
      return nil if @warranty_expires == parsed_date
      @warranty_expires = parsed_date
      @need_to_update = true
    end


    ###
    ### @return [Boolean] does this item have any purchasing info?
    ###
    def has_purchasing?
      @applecare_id or \
      @is_leased or \
      @is_purchased or \
      @lease_expires or \
      @life_expectancy or \
      @po_date or \
      @po_number or \
      @purchase_price or \
      @purchasing_account or \
      @purchasing_contact or \
      @vendor or \
      @warranty_expires
    end

    ###
    ### All the purchasing data in a Hash, as it comes from the API.
    ###
    ### The reason it isn't stored this way is to prevent editing of the hash directly.
    ###
    ### @return [Hash<String>] the location data
    ###
    def purchasing
      {
        :applecare_id => @applecare_id,
        :is_leased => @is_leased,
        :is_purchased => @is_purchased,
        :lease_expires => @lease_expires,
        :life_expectancy => @life_expectancy,
        :po_date => @po_date,
        :po_number => @po_number,
        :purchase_price => @purchase_price,
        :purchasing_account => @purchasing_account,
        :purchasing_contact => @purchasing_contact,
        :vendor => @vendor,
        :warranty_expires => @warranty_expires,
      }
    end

    ###
    ### @api private
    ###
    ### Call this during initialization of
    ### objects that have a Purchasing subset
    ### and the purchasing attribute will be populated
    ### from @init_data
    ###
    def parse_purchasing
      return unless @init_data[:purchasing]

      @purchasing = @init_data[:purchasing]

      @lease_expires = JSS.epoch_to_time  @purchasing[:lease_expires_epoch]
      @po_date = JSS.epoch_to_time  @purchasing[:po_date_epoch]
      @warranty_expires = JSS.epoch_to_time  @purchasing[:warranty_expires_epoch]

      @applecare_id = @purchasing[:applecare_id]
      @is_leased = @purchasing[:is_leased]
      @is_purchased = @purchasing[:is_purchased]
      @life_expectancy = @purchasing[:life_expectancy]
      @po_number = @purchasing[:po_number]
      @purchase_price = @purchasing[:purchase_price].to_f if @purchasing[:purchase_price]
      @purchasing_account = @purchasing[:purchasing_account]
      @purchasing_contact = @purchasing[:purchasing_contact]
      @vendor = @purchasing[:vendor]
    end

    ###
    ### @api private
    ###
    ### @return [REXML::Element] A <purchasing> element to be
    ###   included in the rest_xml of objects that mix-in this module.
    ###
    def purchasing_xml
      purch = REXML::Element.new('purchasing')

      purch.add_element('applecare_id').text = @applecare_id
      purch.add_element('is_leased').text = @is_leased
      purch.add_element('is_purchased').text = @is_purchased.to_s
      purch.add_element('lease_expires_epoch').text = @lease_expires ? @lease_expires.to_jss_epoch : nil
      # Note, life expectancy can't be an empty xml element, it must be zero if emtpy.
      purch.add_element('life_expectancy').text = @life_expectancy ? @life_expectancy : 0
      purch.add_element('po_date_epoch').text = @po_date ? @po_date.to_jss_epoch : nil
      purch.add_element('po_number').text = @po_number
      purch.add_element('purchase_price').text = @purchase_price
      purch.add_element('purchasing_account').text = @purchasing_account
      purch.add_element('purchasing_contact').text = @purchasing_contact
      purch.add_element('vendor').text = @vendor
      purch.add_element('warranty_expires_epoch').text = @warranty_expires ? @warranty_expires.to_jss_epoch : nil
      return purch
    end

    ### Aliases
    alias leased? is_leased
    alias purchased? is_purchased

  end # module Purchasable
end # module JSS
