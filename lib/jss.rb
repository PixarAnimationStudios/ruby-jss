### Author::    Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
### Copyright:: Copyright (c) 2014 Pixar Animation Studios

###
### JSS, A Ruby module for interacting with the JAMF Software Server via it's API.
###
###
module JSS

  #####################################
  ### Required Libraries, etc
  #####################################
  
  ###################
  ### Standard Libraries
  require 'date'
  require 'singleton'
  require 'pathname'
  require 'fileutils'
  require 'tempfile'
  require 'uri'
  require 'cgi'
  require "ipaddr"
  require "rexml/document"
  
  ###################
  ### Gems
  require 'mysql'
  require 'rest-client'
  require 'json'
  


  #####################################
  ### Constants
  #####################################

  ### The minimum JSS version that works with this gem, as returned by the API
  ### in the deprecated 'jssuser' resource
  MINIMUM_SERVER_VERSION = "9.32"

  ### The current local UTC offset as a fraction of a day  (Time.now.utc_offset is the offset in seconds,
  ### 60*60*24 is the seconds in a day)
  TIME_ZONE_OFFSET =  Rational(Time.now.utc_offset, 60*60*24)

  ### This is the current local UTC offset
  ### the default, non-site
  NO_SITE = {:name=>"None", :id=>-1}

  ### These are handy for testing values without making new arrays, strings, etc every time.
  TRUE_FALSE = [true, false]


  #####################################
  ### Module Variables
  #####################################

  #####################################
  ### Module Methods
  #####################################

  ###
  ### Get the current IP address as a String.
  ###
  ### This handy code doesn't acutally make a UDP connection,
  ### it just starts to set up the connection, then uses that to get
  ### the local IP.
  ###
  ### Lifted gratefully from
  ### http://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/
  ###
  ### @return [String] the current IP address.
  ###
  def self.my_ip_address
    ### turn off reverse DNS resolution temporarily
    ### @note the 'socket' library has already been required by 'rest-client'
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true

    UDPSocket.open do |s|
      s.connect '192.168.0.0', 1
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end



  ###
  ### Given a list of data as a comma-separated string, or an Array of strings,
  ### return a Hash with both versions.
  ###
  ### Some parts of the JSS require lists as comma-separated strings, while
  ### often those data are easier work with as arrays. This method is a handy way
  ### to get either form when given either form.
  ###
  ### @param somedata [String, Array] the data to parse, of either class,
  ###   e.g. "foo, bar, baz" -or- ["foo", "bar", "baz"]
  ### @return [Hash{:stringform => String, :arrayform => Array}] the data as both comma-separated String and Array
  ###   e.g. :stringform => "foo, bar, baz", :arrayform => ["foo", "bar", "baz"]
  ###
  def self.to_s_and_a (somedata)
    case somedata
      when String
        valstr = somedata
        valarr = somedata.split(/,\s*/)
      when Array
        valstr = somedata.join ", "
        valarr = somedata
      else
        raise JSS::InvalidDataError, "Input must be a comma-separated String or an Array of Strings"
    end # case
    return {:stringform => valstr, :arrayform => valarr}
  end # to_s_and_a

  ###
  ### Converts an OS Version into an Array of higher OS versions.
  ###
  ### It's unlikely that this library will still be in use as-is by the release of OS X 10.19.15.
  ### Hopefully well before then JAMF will implement a "minimum OS" in the JSS itself.
  ###
  ### @param min_os [String] the mimimum OS version to expand, e.g. ">=10.6.7"  or "10.6.7"
  ### @return [Array] Nearly all potential OS versions from the minimum to 10.19.x
  ###   ["10.6.7", "10.6.8","10.6.9","10.6.10","10.6.11","10.6.12","10.6.13","10.6.14","10.6.15","10.7.x","10.8.x","10.9.x","10.10.x" ...]
  ###   (up to "10.19.x")
  ###
  def self.expand_min_os (min_os)

    min_os.delete! ">="

    ### split the version into major, minor and maintenance release numbers
    (maj,min,maint) = min_os.split(".")
    maint = "x" if maint.nil? or maint == "0"

    ### if the maint release number is an "x" just start the list of OK OS's with it
    if maint == "x"
      ok_oses = [maj + "." + min.to_s + ".x"]

    ### otherwise, start with it and explicitly add all maint releases up to 15
    ### (and hope apple doesn't do more than 15 maint releases for an OS)
    else
      ok_oses = []
      (maint.to_i..15).each do |m|
        ok_oses <<  maj + "." + min +"." + m.to_s
      end # each m
    end

    ### now account for all OS X versions starting with 10.
    ### up to at least 10.19.x
    ((min.to_i + 1)..19).each do |v|
      ok_oses <<  maj + "." + v.to_s + ".x"
    end # each v
    return ok_oses
  end

  ###
  ### Converts a String, Integer or nil to a DateTime
  ### (see String#to_jss_datetime)
  ###
  ### @param a_datetime [String, Integer, nil]
  ### @return [DateTime, nil]
  ###   nil is returned if a_datetime is nil, 0 or an empty String.
  ###
  def self.parse_datetime(a_datetime)
    case a_datetime
      when NilClass
        nil
      when 0
        nil
      when ""
        nil
      else
        a_datetime.to_s.to_jss_datetime
    end
  end #parse_date

  ###
  ### Given a string of xml element text, escape any characters that would make
  ### XML unhappy.
  ###   * & => &amp;
  ###   * " => &quot;
  ###   * < => &lt;
  ###   * > => &gt;
  ###   * ' => &apos;
  ###
  ### @param string [String] the string to make xml-compliant.
  ### @return [String] the xml-compliant string
  ###
  def self.escape_xml(string)
    string.gsub(/&/, '&amp;').gsub(/\"/, '&quot;').gsub(/>/, '&gt;').gsub(/</, '&lt;').gsub(/'/, '&apos;')
  end

  ###
  ### Given an element name and an array of content, generate an Array of
  ### REXML::Element objects with that name, and matching content.
  ### The array of REXML elements would render thus:
  ###     <foo>bar</foo>
  ###     <foo>morefoo</foo>
  ###
  ### @param element [#to_s] an element_name like :foo,
  ### @param list [Array<#to_s>] an Array of element content such as ["bar", :morefoo]
  ### @return [Array<REXML::Element>]
  ###
  def self.array_to_rexml_array(element,list)
    raise JSS::InvalidDataError, "Arg. must be an Array." unless list.kind_of? Array
    element = element.to_s
    list.map do |v|
      e = REXML::Element.new(element)
      e.text = v
      e
    end
  end

  ###
  ### Given a simple Hash, convert it to an array of REXML Elements such that each
  ### key becomes an element, and its value becomes the text content of
  ### that element
  ###
  ### @example
  ###   my_hash = {:foo => "bar", :baz => :morefoo}
  ###   xml = JSS.hash_to_rexml_array(my_hash)
  ###   xml.each{|x| puts x }
  ###
  ###   <foo>bar</foo>
  ###   <baz>morefoo</baz>
  ###
  ### @param hash [Hash{#to_s => #to_s}] the Hash to convert
  ### @return [Array<REXML::Element>] the Array of REXML elements.
  ###
  def self.hash_to_rexml_array(hash)
    raise InvalidDataError, "Arg. must be a Hash." unless hash.kind_of? Hash
    ary = []
    hash.each_pair do |k,v|
      el = REXML::Element.new k.to_s
      el.text = v
      ary << el
    end
    ary
  end


  ###
  ### Given an Array of Hashes with :id and/or :name keys, return
  ### a single REXML element with a sub-element for each item,
  ### each of which contains a :name or :id element.
  ###
  ### @param list_element [#to_s] the name of the XML element that contains the list.
  ###   e.g. :computers
  ### @param item_element [#to_s] the name of each XML element in the list,
  ###   e.g. :computer
  ### @param item_list [Array<Hash>] an Array of Hashes each with a :name or :id key, e.g.
  ###   [{:id=>2,:name=>'kimchi'},{:id=>5,:name=>'mantis'}]
  ### @param content [Symbol] which hash key should be used as the content of if list item?
  ###   :name or :id, defaults to :name
  ###
  ### @return [REXML::Element]
  ###
  ### @example
  ###   comps = [{:id=>2,:name=>'kimchi'},{:id=>5,:name=>'mantis'}]
  ###   xml = JSS.item_list_to_rexml_list(:computers, :computer , comps, :name)
  ###   puts xml
  ###   # output manually formatted for clarity. No newlines in the real xml string
  ###   <computers>
  ###     <computer>
  ###       <name>kimchi</name>
  ###     </computer>
  ###     <computer>
  ###       <name>mantis</name>
  ###     </computer>
  ###   </computers>
  ###
  ###   # if content is :id, then, eg. <name>kimchi</name> would be <id>2</id>
  ###
  def self.item_list_to_rexml_list(list_element, item_element , item_list, content = :name)
    xml_list = REXML::Element.new  list_element.to_s
    item_list.each do |i|
      xml_list.add_element(item_element.to_s).add_element(content.to_s).text = i[content]
    end
    xml_list
  end


  ###
  ### Parse a JSS Version number into something comparable
  ###
  ### Unfortunately, the JSS version numbering is inconsistant and improper at the moment.
  ### Version 9.32 should be version 9.3.2, so that it
  ### will be recognizable as being less than 9.4
  ###
  ### To work around this until JAMF standardizes version numbering,
  ### we will assume any digits before the first dot is the major version
  ### and the first digit after the first dot is the minor version
  ### and anything else, including other dots, is the revision
  ###
  ### If that revision starts with a dot, it is removed.
  ### so 9.32 becomes  major-9, minor-3, rev-2
  ### and 9.32.3764 becomes major-9, minor-3, rev-2.3764
  ### and 9.3.2.3764 becomes major-9, minor-3, rev-2.3764
  ###
  ### This method of parsing will break if the minor revision
  ### ever gets above 9.
  ###
  ### Returns a hash with these keys:
  ### * :major => the major version, Integer
  ### * :minor => the minor version, Integor
  ### * :revision => the revision, String
  ### * :version => a Gem::Version object built from the above keys, which is easily compared to others.
  ###
  ### @param version[String] a JSS version number from the API
  ###
  ### @return [Hash{Symbol => String, Gem::Version}] the parsed version data.
  ###
  def self.parse_jss_version(version)
    spl = version.split('.')

    case spl.count
      when 1
        major = spl[0].to_i
        minor = 0
        revision = '0'
      when 2
        major = spl[0].to_i
        minor = spl[1][0,1].to_i
        revision = spl[1][1..-1]
        revision = '0' if revision.empty?
      else
        major = spl[0].to_i
        minor = spl[1][0,1].to_i
        revision = spl[1..-1].join('.')[1..-1]
        revision = revision[1..-1] if revision.start_with? '.'
    end

    ###revision = revision[1..-1] if revision.start_with? '.'
    { :major => major,
      :minor => minor,
      :revision => revision,
      :version => Gem::Version.new("#{major}.#{minor}.#{revision}")
    }
  end

  ###
  ### Define classes and submodules here so that they don't
  ### generate errors when referenced during the loading of
  ### the library.
  ###

  #####################################
  ### Sub Modules
  #####################################

  ### Mix-in Sub Modules

  module Creatable ; end
  module FileUpload ; end
  module Locatable ; end
  module Matchable ; end
  module Purchasable ; end
  module Updatable ; end

  ### Mix-in Sub Modules with Classes

  module Criteriable ; end
  class Criteriable::Criteria ; end
  class Criteriable::Criterion ; end

  module Scopable ; end
  class Scopable::Scope ; end

  #####################################
  ### Classes
  #####################################

  class APIObject ; end
  class APIConnection ; end
  class Client ; end
  class DBConnection ; end
  class Server ; end

  #####################################
  ### SubClasses
  #####################################

  ### APIObject Classes with SubClasses

  class AdvancedSearch < JSS::APIObject ; end
  class AdvancedComputerSearch < JSS::AdvancedSearch ; end
  class AdvancedMobileDeviceSearch < JSS::AdvancedSearch ; end
  class AdvancedUserSearch <  JSS::AdvancedSearch ; end


  class ExtensionAttribute < JSS::APIObject ; end
  class ComputerExtensionAttribute < JSS::ExtensionAttribute ; end
  class MobileDeviceExtensionAttribute < JSS::ExtensionAttribute ; end
  class UserExtensionAttribute < JSS::ExtensionAttribute ; end

  class Group < JSS::APIObject ; end
  class ComputerGroup < JSS::Group ; end
  class MobileDeviceGroup < JSS::Group ; end
  class UserGroup < JSS::Group ; end

  class Report < JSS::APIObject ; end
  class ComputerReport < JSS::Report ; end

  ### APIObject Classes without SubClasses

  class Building < JSS::APIObject ; end
  class Category < JSS::APIObject ; end
  class Computer < JSS::APIObject ; end
  class Department < JSS::APIObject ; end
  class DistributionPoint < JSS::APIObject ; end
  class MobileDevice < JSS::APIObject ; end
  class NetbootServer < JSS::APIObject ; end
  class NetworkSegment < JSS::APIObject ; end
  class Package < JSS::APIObject ; end
  class PeripheralType < JSS::APIObject ; end
  class Peripheral < JSS::APIObject ; end
  class Policy < JSS::APIObject ; end
  class RemovableMacAddress < JSS::APIObject ; end
  class Script < JSS::APIObject ; end
  class SoftwareUpdateServer < JSS::APIObject ; end
  class User < JSS::APIObject ; end


end # module JSS


##################
### Load the rest of the module
$:.unshift File.dirname(__FILE__)

require "jss/compatibility"
require "jss/ruby_extensions"
require "jss/exceptions"
require "jss/api"
require "jss/api_object"
require "jss/server"
require "jss/client"
require "jss/db"
