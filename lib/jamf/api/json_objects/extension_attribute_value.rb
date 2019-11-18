# Copyright 2019 Pixar

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

# The module
module Jamf

  # An extension attribute in Jamf Pro
  class ExtensionAttributeValue < Jamf::JSONObject

    OBJECT_MODEL = {

      # @!attribute [r] id
      #   The id of the attribute defining this value
      #   @return [Integer]
      id: {
        class: :integer,
        readonly: true
      },

      # @!attribute [r] name
      #   The name of the attribute defining this value
      #   @return [String]
      name: {
        class: :string,
        readonly: true
      },

      # @!attribute [r] type
      #   The value_type of this value
      #   @return [String]
      type: {
        class: :string,
        enum: Jamf::ExtensionAttribute::VALUE_TYPES,
        readonly: true
      },

      # @!attribute [r] value
      #   The value stored for this managed object for this ext attr
      #   Settable via #new_value=
      #   @return [String]
      value: {
        class: :string,
        readonly: true # settable via Extendable#set_ext_attr
      }

    }.freeze
    parse_object_model

    # TODO: The WebApp doesn't seem to support enforcement of Data types..
    #  I can enter any string as a DATE ea, an that string comes through as the
    #  value.
    #

    def initialize(data, cnx: Jamf.cnx)
      super
      return if @value.nil?
      @value =
        case @type
        when :integer
          @value.j_integer? ? @value.to_i : "INVALID INTEGER: #{@value}"
        when :date
          Jamf::TimeStamp.new @value, cnx: cnx
        else
          @value
        end # case
    end # init

    # setter for values. Usually called by
    # Extendable#set_ext_attr
    def new_value=(new_val)

      # nil unsets the value
      unless new_val.nil?
        new_val =
          case @type
          when :integer
            Jamf::Validate.integer new_val, "Value for ext. attr. #{@name} must be an integer"
          when :date
            validate_date new_val
          else
            new_val.to_s
          end # case
      end # unless nil

      old_val = @value
      return if old_val == new_val
      @value = new_val
      note_unsaved_change(:value, old_val)
    end

    # the to_jamf in JSONObject would skip all these
    # cuz they are read-only
    # but we need them here.
    def to_jamf
      return unless unsaved_changes?

      new_val = @type == :date ? @value.to_jamf : @value.to_s
      {
        id: @id,
        value: new_val
      }
    end

  end # class ext attr

end # module
