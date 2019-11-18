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

  # CollectionResource Class instances with this module mixed-in can be
  # referred to in other classes.
  #
  # Doing so dynamically defines a new 'Reference' class, which is a
  # subclass of {Jamf::GenericReference}
  #
  # Examples:
  #
  # 1) A Policy can have a category assigned to it, and the policy's API data
  # will contain a reference to a category.
  #
  # Jamf::Policy instances have a :category attribute, which contains an
  # instance of Jamf::Category::Reference
  #
  # Mixing Referable into Jamf::Category automatically creates the class
  # Jamf::Category::Reference
  #
  # 2) The API data for a Jamf::ComputerGroup contains a an Array of references
  # to member Jamf::Computers. That Array arrives in JSON like this:
  #
  #  computers: [
  #    { id: 234, name: 'foobar' },
  #    { id: 698, name: 'barfoo' }
  #  ]
  #
  # Mixing Referable into Jamf::Computer defines the class
  # Jamf::Computer::Reference and allows Jamf::ComputerGroups to maintain an
  # array of Jamf::Computer::Reference objects representing that list.
  # When needed to send to the API, it will send this:
  #
  #  computers: [
  #    { id: 234 },
  #    { id: 698 }
  #  ]
  #
  # Parsing the API data into Reference instances, and converting them back for
  # the API is handled by the Reference class.
  #
  # TODO: Handle if any references contain keys other than :id and :name.
  #
  module Referable

    # this will hopefully autoload generic_reference
    GENREF = Jamf::GenericReference

    # This is run when Referable is included in some class 'referent'
    # It creates class referent::Reference as a subclass of
    # GenericReference, and sets the REFERENT_CLASS constant of
    # referent::Reference to referent.
    #
    def self.included(referent)
      raise JSS::InvalidDataError, "'#{referent}' is not a subclass of Jamf::CollectionResource, can't include 'Referable'" unless referent.ancestors.include? Jamf::CollectionResource
      referent.const_set :Reference, Class.new(GENREF)
      referent::Reference.const_set :REFERENT_CLASS, referent
    end

    # @return [self.class::GenericReference] A reference to this object.
    #
    def reference
      @reference ||= self.class::Reference.new self
    end

  end # module Referable

end # module
