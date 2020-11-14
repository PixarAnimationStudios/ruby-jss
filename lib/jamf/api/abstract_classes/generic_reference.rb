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

module Jamf

  # TODO:  This class and the referable mixin should be removed -
  # According to the Jamf Pro API Styleguide/Specs:
  #
  #   - Objects which reference other objects MUST only reference by its Jamf Pro-assigned numerical ID.
  #
  # and in newer endpoints that is what we're seeing, e.g. fields like
  # 'siteId' and 'categoryId'

  # This class is a reference to an individual API object from some other
  # API object.
  #
  # This class is subclassed automatically when the {Jamf::Referable} module
  # is included into a class.
  #
  # See {Jamf::Referable} for how to use the subclasses of GenericReference.
  #
  # Subclasses must define:
  #
  # REFERENT_CLASS - the full class to which this is a reference
  # e.g. for BuildingReference it would be Jamf::Building
  #
  # Defining REFERENT_CLASS is handled automatically by including the
  # Referable module
  #
  # @abstract
  #
  class GenericReference < Jamf::JSONObject

    extend Jamf::Abstract

    # Constants
    #####################################

    OBJECT_MODEL = {

      id: {
        class: :j_id,
        identifier: :primary,
        readonly: true
      },

      name: {
        class: :string,
        readonly: true
      }

    }.freeze
    parse_object_model

    # Constructor
    #####################################

    # Make a new reference to an API CollectionResource Object
    #
    # The data parameter can be one of:
    #
    # 1) A Hash with an :id and :name
    #    This is mostly used automatically when parsing fetched API data.
    #    When some attribute of an OBJECT_MODEL has `class: Someclass::Reference`
    #    the JSON hash from the API will be passed as the data param.
    #
    #    e.g.
    #    - Policy::OBJECT_MODEL[:category][:class] is Jamf::Category::Reference
    #    - the policy JSON from the api might contain `category: { id: 234, name: 'foobar' }`
    #    - that hash will be passed into Jamf::Category::Reference.new, and the
    #      resulting instance used as the value of the  policy's :category attribute.
    #
    # 2) An instance of the REFERENT_CLASS.
    #   This can be used to make a reference to some specific instance of
    #   the referent class.
    #
    #   e.g. if you have an instance of Category in the variable `my_cat`
    #   then `ref_to_my_cat = Category::Reference.new my_cat` will work as
    #   expected.
    #
    # 3) A valid identifier for an existing REFERENT_CLASS in the JSS.
    #    The given value will be used with the REFERENT_CLASS's .valid_id method
    #    to see if there's a matching instance, which the reference refers to.
    #
    #    e.g. `ref_to_my_cat = Category::Reference.new 12` creates a reference
    #    to Category id 12, and `ref_to_my_cat = Category::Reference.new 'foo'`
    #    creates a reference to the category named 'foo' - assuming they exist.
    #
    # The last two of these are commonly used with setters for attributes that
    # have class: <some reference class>
    #
    # e.g. setting the category of a policy when
    # Policy::OBJECT_MODEL[:category] is Category::Reference
    #
    #   `mypolicy.category = a_cat` # a_cat is a Category instance
    #   `mypolicy.category = 12`    # use categoty id 12
    #   `mypolicy.category = 'foo'` # use categoty named 'foo'
    #
    #
    #
    # @param data[Hash,CollectionResource,String,Integer]
    #
    def initialize(data, cnx: Jamf.cnx)
      ref_class = self.class::REFERENT_CLASS
      case data
      when Hash
        super
      when ref_class
        raise Jamf::InvalidDataError, "Provided #{ref_class} hasn't been created" unless data.exist?
        @id = data.id
        @name = data.name if data.respond_to? :name
        @cnx = data.cnx
      when nil
        @id = nil
        @name = nil
        @cnx = cnx
      else
        @id = ref_class.valid_id data, cnx: cnx
        raise "No matching #{ref_class}" unless @id
        @name = ref_class.map_all(:id, to: :name, cnx: cnx)[@id]
      end
    end

    def to_jamf
      return nil if @id.nil?
      { id: @id }
    end

  end # class

end # module
