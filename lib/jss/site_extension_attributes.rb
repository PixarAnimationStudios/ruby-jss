# = site_extension_attributes.rb
#
# Author:: Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
# Copyright:: Copyright (c) 2013 Pixar Animation Studios
#
# A mix-in module for adding site-specific Extention Attributes to
# the JSS::Computer class
#

module PixJSS

  ### 
  ### A SubModule for mixing in to JSSComputers, adding constants and methods
  ### that give access to Exetension Attribute Values & other customized inventory data
  ### defined for this installation of the JSS.
  ###
  ### For general access to the raw Extension Attribute data as it's stored in the JSS, see
  ### extension_attribute.rb.
  ###
  module SiteExtensionAttributes
  
    ###############################
    # Class Constants
    ###############################
    
    #######
    # The Extension Attribute Names
    # REST returns the most recently report value for each extention attribute,
    # along with its display name. Here are the ones we might like to use.
    # so that if we change the names in the JSS, we only have to change this 
    # value.
    
    EA_LAST_FULL_BU = "backups-last-full"
    EA_LAST_INCR_BU = "backups-last-incremental"
    EA_VIRUS_DEFS_DATE = "Sophos - Virus Definition Date"
    EA_VIRUS_DEFS_VERS = "Sophos - Virus Definition Version"
    EA_D3_INSTALLS = "d3installs"
    EA_USER_INSTALLED_APPS = "User-installed Apps"
    EA_LDAP_SERVER = "net-ldap-svr"
    EA_GEO_LOCATION = "IP Geo-Location"
    EA_BATTERY_HEALTH = "Battery Health Status"
    EA_BATTERY_CYCLES = "Battery Cycle Count"
  
    ###############################
    # Instance Methods
    ###############################
    
    ###
    ### Return a DateTime with the last full backup, as of the last recon
    ### 
    def last_full_backup
      DateTime.parse raw_ea[EA_LAST_FULL_BU]
    end
    
    ###
    ### Return a DateTime with the last incremental backup, as of the last recon
    ### 
    def last_incr_backup
      DateTime.parse raw_ea[EA_LAST_INCR_BU]
    end
    
    ### 
    ### An Array of Hashes: the installed d3 items as of the last
    ### recon.
    ### Each hash has these keys
    ###   :basename String
    ###   :vers String
    ###   :rev FixNum
    ###   :when DateTime (the time it was installed)
    ###   :by String (the admin who installed it)
    ###   :pilot Boolean
    ###   :type Symbol, either :auto or :manual
    ###
    def d3_installs
      return @d3_installs if @d3_installs
      @d3_installs = []
      raw_ea[EA_D3_INSTALLS].split("\n").each do |i|
        data = i.split "::"
        @d3_installs << {
          :basename => data[0],
          :vers =>  data[1],
          :rev => data[2].to_i,
          :when => DateTime.parse(data[3]),
          :by => data[4],
          :pilot => data[5].to_sym == :pilot ? true : false,
          :type => data[6].to_sym
        }
      end
      return @d3_installs
    end
    
    ###
    ### An Array of Hashes, as defined for the d3_installs method
    ### but only limited to pilots
    ###
    def d3_pilots
      d3_installs.select {|i| i[:pilot] }
    end
    
    ###
    ### An Array of Hashes, as defined for the d3_installs method
    ### but only limited to manual installs
    ###
    def d3_manual_installs
      d3_installs.select {|i| i[:type] == :manual }
    end
    
    ###
    ### Return a string, The "function" (subclass) as listed in LDAP, and brought into
    ### the JSS via receipts and smart groups
    ### There should only be two subclasses total; one for the formfactor
    ### and one for the function. All other data should be tags. (see the ldap_tags method)
    ###
    def ldap_function
      computer_groups.select{|i| i.start_with? "ldap.func" and not i.end_with? ".not"}[0].sub /^ldap\.func\./, ''
    end
    
    ###
    ### Return an Array of strings, The ldap tags, brought into
    ### the JSS via receipts and smart groups
    ###
    def ldap_tags
      computer_groups.select{|i| i.start_with? "ldap.tag."}.map{|t| t.split('.').last}
    end
    
    ###
    ### Array of Hashs - the history of reported IP GeoLocations for this computer.
    ### Each hash has 2 keys, :value (String, and :timestamp (DateTime)
    ###
    def geo_history
      geo_ext_attr = PixJSS::JSSExtAttrib.new :lookup => true, :name => EA_GEO_LOCATION
      geo_ext_attr.history self.id
    end
  end # module ext attribs
  
  # now mix it in to the Computers class
  
  class JSSComputer
    include PixJSS::SiteExtensionAttributes
  end # class
  
end # module pixjss