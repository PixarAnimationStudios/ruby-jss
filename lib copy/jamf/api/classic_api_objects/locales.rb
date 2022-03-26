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
  class Locales < Jamf::SingletonResource

    # Mix-Ins
    #####################################

    extend Jamf::Immutable

    # Constants
    #####################################

    RSRC_VERSION = 'v1'.freeze

    RSRC_PATH = 'locales'.freeze

    OBJECT_MODEL = {

      # @!attribute checkInFrequency
      #   @return [integer]
      locales: {
        class: Jamf::Locale,
        multi: true,
        read_only: true,
        aliases: [:list]
      }

    }.freeze # end OBJECT_MODEL

    parse_object_model

    # TEMP? until this endpoint is brought up to standards
    # the data from the API is a raw Array, but it should be a
    # Hash containing an array.
    def initialize(data, cnx: Jamf.cnx)
      data = { locales: data }
      super data, cnx: cnx
    end

    # Class Methods
    #####################################

    # @return [Array<Jamf::Locale>] all the locales available
    #
    def self.list(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).locales
    end

    # Class level wrapper for #descriptions
    def self.descriptions(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).descriptions
    end
    # how to alias a class method
    singleton_class.send(:alias_method, :names, :descriptions)

    # Class level wrapper for #identifiers
    def self.identifiers(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).identifiers
    end
    singleton_class.send(:alias_method, :ids, :identifiers)

    # Class level wrapper for #ids_by_desc
    def self.ids_by_desc(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).ids_by_desc
    end

    # Class level wrapper for #descs_by_id
    def self.descs_by_id(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).descs_by_id
    end

    # Class level wrapper for #id_for_desc
    def self.id_for_desc(desc, refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).id_for_desc desc
    end

    # Class level wrapper for #desc_for_id
    def self.desc_for_id(id, refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).desc_for_id id
    end

    # Instance Methods
    #####################################

    # @return [Array<String>] the available descriptions
    def descriptions
      @descriptions ||= locales.map(&:description)
    end
    alias names descriptions

    # @return [Array<String>] the available identifiers
    def identifiers
      @identifiers ||= locales.map(&:identifier)
    end
    alias ids identifiers

    # @return [Hash] name => code
    def ids_by_desc
      @ids_by_desc ||= locales.map { |l| [l.description, l.identifier] }.to_h
    end

    # @return [Hash] code => name
    def descs_by_id
      @descs_by_id ||= locales.map { |l| [l.identifier, l.description] }.to_h
    end

    # return an identifier from its description, case-insensitive
    # @param desc[String] the description of a locale
    # @return [String]
    def id_for_desc(desc)
      desc = descriptions.select { |n| n.casecmp? desc }.first
      ids_by_desc[desc]
    end

    # return a description from its identifier, case-insensitive
    # @param name[String] the identifier of a local
    # @return [String]
    def desc_for_id(id)
      id = identifiers.select { |n| n.casecmp? id }.first
      descs_by_id[id]
    end

  end # class

end # module
