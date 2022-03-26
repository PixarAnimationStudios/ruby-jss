# Copyright 2020 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

# The Module
module Jamf

  # Classes
  #####################################

  # A list of known timezones
  class TimeZones < Jamf::SingletonResource

    # Mix-Ins
    #####################################

    extend Jamf::Immutable

    # Constants
    #####################################

    RSRC_VERSION = 'v1'.freeze

    RSRC_PATH = 'time-zones'.freeze

    OBJECT_MODEL = {

      # @!attribute checkInFrequency
      #   @return [integer]
      timeZones: {
        class: Jamf::TimeZone,
        multi: true,
        read_only: true,
        aliases: [:list]
      }

    }.freeze # end OBJECT_MODEL

    # TEMP? until this endpoint is brought up to standards
    # the data from the API is a raw Array, but it should be a
    # Hash containing an array.
    def initialize(data, cnx: Jamf.cnx)
      data = { timeZones: data }
      super data, cnx: cnx
    end



    # Class Methods
    #####################################

    # @return [Array<Jamf::TimeZone>] all the zomes available
    #
    def self.list(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).timeZones
    end

    # Class level wrapper for #displayNames
    def self.displayNames(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).displayNames
    end
    singleton_class.send(:alias_method, :names, :displayNames)

    # Class level wrapper for #zoneIds
    def self.zoneIds(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).zoneIds
    end
    singleton_class.send(:alias_method, :ids, :zoneIds)

    # Class level wrapper for #regions
    def self.regions(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).regions
    end

    # Class level wrapper for #ids_by_name
    def self.ids_by_name(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).ids_by_name
    end

    # Class level wrapper for #names_by_id
    def self.names_by_id(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).names_by_id
    end

    # Class level wrapper for #regions_by_id
    def self.regions_by_id(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).regions_by_id
    end

    # Class level wrapper for #regions_by_name
    def self.regions_by_name(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).regions_by_name
    end

    # Class level wrapper for #id_for_name
    def self.id_for_name(name, refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).id_for_name name
    end

    # Class level wrapper for #name_for_id
    def self.name_for_id(id, refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).name_for_id id
    end

    # Class level wrapper for #region_for_name
    def self.region_for_name(name, refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).region_for_name name
    end

    # Class level wrapper for #name_for_id
    def self.region_for_id(id, refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).region_for_id id
    end


    # Instance Methods
    #####################################

    # @return [Array<String>] the available zone names
    def displayNames
      @names ||= timeZones.map(&:displayName)
    end
    alias names displayNames

    # @return [Array<String>] the available zone ids
    def zoneIds
      @ids ||= timeZones.map(&:zoneId)
    end
    alias ids zoneIds

    # @return [Array<String>] the available zone regions
    def regions
      @regions ||= timeZones.map(&:region).uniq
    end

    # @return [Hash] name => id
    def ids_by_name
      @ids_by_name ||= timeZones.map { |tz| [tz.displayName, tz.zoneId] }.to_h
    end

    # @return [Hash] id => name
    def names_by_id
      @names_by_id ||= timeZones.map { |tz| [tz.zoneId, tz.displayName] }.to_h
    end

    # @return [Hash] id => region
    def regions_by_id
      @regions_by_id ||= timeZones.map { |tz| [tz.zoneId, tz.region] }.to_h
    end

    # @return [Hash] name => region
    def regions_by_name
      @regions_by_name ||= timeZones.map { |tz| [tz.displayName, tz.region] }.to_h
    end

    # return a zone id from its name, case-insensitive
    # @param name[String] the name of a zone
    # @return [String]
    def id_for_name(name)
      name = names.select { |n| n.casecmp? name }.first
      ids_by_name[name]
    end

    # return a zone name from its id, case-insensitive
    # @param name[String] the name of a zone
    # @return [String]
    def name_for_id(id)
      id = ids.select { |n| n.casecmp? id }.first
      names_by_id[id]
    end

    # return a zone name from its id, case-insensitive
    # @param name[String] the name of a zone
    # @return [String]
    def region_for_name(name)
      name = names.select { |n| n.casecmp? name }.first
      regions_by_name[name]
    end

    # return a zones from its id, case-insensitive
    # @param name[String] the name of a zone
    # @return [String]
    def region_for_id(id)
      id = ids.select { |n| n.casecmp? id }.first
      regions_by_id[id]
    end

  end # class

end # module
