module JSS
  
  #####################################
  ### Classes
  #####################################
  
  ### 
  ### A peripheral_type in the JSS
  ###
  ### See also JSS::APIObject
  ###
  class PeripheralType  < JSS::APIObject
    
    #####################################
    ### MixIns
    #####################################

    include JSS::Creatable
    include JSS::Updatable
    
    #####################################
    ### Class Methods
    #####################################
    
    #####################################
    ### Class Constants
    #####################################
    
    ### The base for REST resources of this class
    RSRC_BASE = "peripheraltypes"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :peripheral_types
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :peripheral_type
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = [:fields]
    
    ### field types can be one of these, either String or Symbol
    FIELD_TYPES = [:text, :menu]
    
    #####################################
    ### Attributes
    #####################################
    
    ### :fields - an Array of (mostly) Hashes 
    ### The field definitions for this type of periph,
    ### in the order in which the fields appear in the Periph UI
    ### The first element of the hash is always nil, so that the one-based
    ### :order of the field matches it's Array index.
    ###
    ### Each hash has these keys about the field it describes
    ###   :name - String, the name of the field
    ###   :type - String, the kind of data to be stored in the field, one of "text" or "menu"
    ###   :choices - Array of Strings - if type is "menu" these are the menu choices.
    ###   :order - the one-based number of this field amid it's peers.
    ###
    ### Fields come from the API as an array of hashes, with those keys.
    ### Since Arrays are zero-based, and the field order is one-based, keeping 
    ### a nil at the front of the Array will keep the order number in sync with the
    ### Array index of each field.This is done automatically by the field-editing 
    ### methods. #fields=, #set_field, #append_field, #prepend_field, #insert_field
    ### and #delete_field.
    ###
    ### So the Array from the API comes like this:
    ### [ {:type=>"text", :order=>1, :choices=>[], :name=>"make"},
    ###   {:type=>"text", :order=>2, :choices=>[], :name=>"model"},
    ###   {:type=>"text", :order=>3, :choices=>[], :name=>"family"},
    ###   {:type=>"text", :order=>4, :choices=>[], :name=>"serialnum"} ]
    ###
    ### But will be stored in Ruby like this:
    ### [ nil,
    ###   {:type=>"text", :order=>1, :choices=>[], :name=>"make"},
    ###   {:type=>"text", :order=>2, :choices=>[], :name=>"model"},
    ###   {:type=>"text", :order=>3, :choices=>[], :name=>"family"},
    ###   {:type=>"text", :order=>4, :choices=>[], :name=>"serialnum"} ]
    ###
    ### therefore @fields[2] will get you the second field, which has :order => 2.
    ###
    attr_reader :fields
    
  
    
    #####################################
    ### Instance Methods
    #####################################

    ###
    ### Initialize
    ###
    def initialize (args = {})
      
      super
      
      @fields = []
      @init_data[:fields].each{ |f|  @fields[f[:order]] = f }
      
    end # initialize
    
    ###
    ### provide a whole new Array of fields
    ### The :order of each will be set based on the indexes of the 
    ### Array provided.
    ###
    def fields= (new_fields)
      unless new_fields.kind_of? Array and  new_fields.reject{|c| c.kind_of? Hash }.empty?
        raise JSS::InvalidDataError, "Argument must be an Array of Hashes."
      end
      raise "A peripheral type can have a maximmum of 20 fields"  if new_fields.count > 20
      new_fields.each{ |f| field_ok? f }
      @fields = new_fields  
      order_fields
    end
     
    ###
    ### Change the details of one specific field
    ### The args are the fild number (:order) of the field being changed.
    ### and the new field hash to put there.
    ### The number must already exist. Otherwise use
    ### #append_field, #prepend_field, or #insert_field
    ###
    def set_field(order, field)
      raise JSS::NoSuchItemError, "No field with number '#{order}'. Use #append_field, #prepend_field, or #insert_field" unless @fields[order]
      field_ok? field
      @fields[order] = field
    end
    
    ###
    ### Add a new field to the end of the field list
    ### The arg is a Hash of the details of the field being added
    ###
    def append_field(field)
      field_ok? field
      @fields << field
      order_fields
    end
    
    ###
    ### Add a new field to the beginning of the field list
    ### The arg is a Hash of the details of the field being added
    ###
    def prepend_field(field)
      field_ok? field
      @fields.unshift field
      order_fields
    end
    
    ###
    ### Add a new field to the middle of the fields list
    ### The args are the field number before which to insert the new one,
    ### and then the hash of field data
    ###
    def insert_field(at,field)
      field_ok? field
      @fields.insert((order -1), field)
      order_fields
    end
    
    ###
    ### Remove a field from the array of fields.
    ### The arg is the field *order*, as it comes from the API, 
    ### which will match the array index.
    ###
    def delete_field(order)
      if @fields[order]
        raise JSS::MissingDataError, "Fields can't be empty" if @fields.count == 1
        @fields.delete_at index
        order_fields
      end
    end
    
  
    
    ##############################
    ### private methods
    ##############################
    ###private
    
    ###
    ### is a Hash of field data OK for use in the JSS?
    ### Return true or raise an exception
    ###
    def field_ok?(field)
      raise JSS::InvalidDataError, "Field elements must be hashes with :name, :type, and possibly :choices" unless field.kind_of? Hash
      raise JSS::InvalidDataError, "Fields require names" if field[:name].to_s.empty?
      raise JSS::InvalidDataError, "Fields :type must be one of: :#{FIELD_TYPES.join(', :')}" unless FIELD_TYPES.include? field[:type].to_sym
      
      if field[:type].to_sym == :menu
        unless field[:choices].kind_of? Array and  field[:choices].reject{|c| c.kind_of? String}.empty?
          raise JSS::InvalidDataError, "Choices for menu fields must be an Array of Strings"
        end # unless
      else
        field[:choices] = []
      end # if type -- menu
      true
    end # def field ok?
    
    ###
    ### Close up gaps in the field order, and make each field's :order match it's array index
    ###
    def order_fields
      @fields.compact!
      @fields.each_index{|i| @fields[i][:order] = i+1}
      @fields.unshift nil
    end
    
    
    ###
    ###
    ###
    def rest_xml
      order_fields
      doc = REXML::Document.new APIConnection::XML_HEADER
      pkg = doc.add_element RSRC_OBJECT_KEY.to_s
      pkg.add_element('id').text = @id
      pkg.add_element('name').text = @name
      fields = pkg.add_element 'fields'

      flds =  @fields.compact
      flds.each_index do |i|
        field = fields.add_element 'field'
        field.add_element('order').text =flds[i][:order]
        field.add_element('name').text = flds[i][:name]
        field.add_element('type').text = flds[i][:type].to_s
        choices = field.add_element('choices')
        unless flds[i][:choices].empty?
          flds[i][:choices].each{|c| choices.add_element('choice').text = c}
        end
      end # each index do i
      return doc.to_s
    end # rest xml
    
  end # class Peripheral
end # module