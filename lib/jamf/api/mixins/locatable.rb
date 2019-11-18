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

module Jamf

  # Classes mixing this in have a Jamf::Location instance in their :location
  # attribute.
  #
  # See the Jamf::JSONObject docs for OBJECT_MODEL for defining the
  # :location attribute. It should always be marked `readonly: true`,
  # since attempting to set the location as a whole will raise an error.
  #
  # Instead of setting it as a whole, you must use the Jamf::Location object
  # stored in the :location attribute to access it's values, like so:
  #
  #   mycomputer.location.department # => 'Muggle Studies'
  #   mycomputer.location.room = 'Great Hall'
  #
  # All location attributes can be set that way, but building, room, department,
  # & phoneNumber are more related to the physical location, so must be used
  # that way.
  #
  # The other attributes, username, realName, position, and emailAddress, are
  # more related to the assinged user than the physical location, and are also
  # acessible via the #user method, which returns a simple wrapper for those
  # attributes, like this:
  #
  #   mycomputer.user.name  # => 'adumble'   user.username works too
  #   mycomputer.user.realName = 'Albus Dumbledore'
  #   mycomputer.user.position = 'Headmaster'
  #   mycomputer.user.emailAddress = 'adumble@hogwarts.edu.uk'
  #
  # are more related to the machine and its physical location
  # than to the user responsible for the machine.
  #
  module Locatable

    def location=(_loc)
      raise Jamf::UnsupportedError, 'Location cannot be set as a whole, set its attributes individually'
    end

    def user
      @location_user ||= Jamf::Locatable::User.new(self)
    end

    # a class for user-specific data in a Location object
    class User

      def initialize(assigned_object)
        @assigned_object = assigned_object
      end

      def username
        @assigned_object.location.username
      end
      alias name username

      def username=(val)
        @assigned_object.location.username = val
      end
      alias name= username=

      def realName
        @assigned_object.location.realName
      end

      def realName=(val)
        @assigned_object.location.realName = val
      end

      def emailAddress
        @assigned_object.location.emailAddress
      end

      def emailAddress=(val)
        @assigned_object.location.emailAddress = val
      end

      def position
        @assigned_object.location.position
      end

      def position=(val)
        @assigned_object.location.position = val
      end

      # Remove large cached items from
      # the instance_variables used to create
      # pretty-print (pp) output.
      #
      # @return [Array] the desired instance_variables
      #
      def pretty_print_instance_variables
        vars = instance_variables.sort
        vars.delete :@assigned_object
        vars
      end

    end # class user

  end # locatable

end # Jamf
