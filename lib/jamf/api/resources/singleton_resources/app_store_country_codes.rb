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

  # The client checkin settings for the Jamf Pro Server
  #
  class AppStoreCountryCodes < Jamf::SingletonResource

    # Constants
    #####################################

    RSRC_VERSION = 'v1'.freeze

    RSRC_PATH = 'app-store-country-codes'.freeze

    OBJECT_MODEL = {

      # @!attribute checkInFrequency
      #   @return [integer]
      countryCodes: {
        class: Jamf::Country,
        multi: true
      }

    }.freeze # end OBJECT_MODEL

    parse_object_model


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
