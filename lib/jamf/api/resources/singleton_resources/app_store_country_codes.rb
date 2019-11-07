# Copyright 2018 Pixar

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

module Jamf

  # The API endpoint for country codes.
  #
  # Probably more useful is the Jamf.app_store_country_codes method
  # which parses this into a hash of Code => Name
  #
  class AppStoreCountryCodes < Jamf::SingletonResource

    extend Jamf::Immutable

    # Constants
    #####################################

    RSRC_VERSION = 'v1'.freeze

    RSRC_PATH = 'app-store-country-codes'.freeze

    OBJECT_MODEL = {

      # @!attribute checkInFrequency
      #   @return [integer]
      countryCodes: {
        class: Jamf::Country,
        multi: true,
        read_only: true
      }

    }.freeze # end OBJECT_MODEL

    parse_object_model

    # Class Methods
    #####################################

    # Class level wrapper for #names
    def self.names(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).names
    end

    # Class level wrapper for #codes
    def self.codes(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).codes
    end

    # Class level wrapper for #codes_by_name
    def self.codes_by_name(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).codes_by_name
    end

    # Class level wrapper for #names_by_code
    def self.names_by_code(refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).names_by_code
    end

    # Class level wrapper for #code_for_name
    def self.code_for_name(name, refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).code_for_name name
    end

    # Class level wrapper for #name_for_code
    def self.name_for_code(code, refresh = false, cnx: Jamf.cnx)
      fetch(refresh, cnx: cnx).name_for_code code
    end

    # Instance Methods
    #####################################

    # @return [Array<String>] the available country names
    def names
      @names ||= countryCodes.map{ |country| country.name }
    end

    # @return [Array<String>] the available country codes
    def codes
      @codes ||= countryCodes.map{ |country| country.code }
    end

    # @return [Hash] name => code
    def codes_by_name
      @codes_by_name ||= countryCodes.map{ |country| [country.name, country.code] }.to_h
    end

    # @return [Hash] code => name
    def names_by_code
      @names_by_code ||= countryCodes.map{ |country| [country.code, country.name] }.to_h
    end

    # return a country code from its name, case-insensitive
    # @param name[String] the name of a country
    # @return [String]
    def code_for_name(name)
      name = names.select { |n| n.casecmp? name }.first
      codes_by_name[name]
    end

    # return a country name from its code, case-insensitive
    # @param name[String] the name of a country
    # @return [String]
    def name_for_code(code)
      names_by_code[code.upcase]
    end

  end # class AppStoreCountryCodes

end # module JAMF
