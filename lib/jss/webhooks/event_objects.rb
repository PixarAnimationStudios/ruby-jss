### Copyright 2016 Pixar
###
###    Licensed under the Apache License, Version 2.0 (the "Apache License")
###    with the following modification; you may not use this file except in
###    compliance with the Apache License and the following modification to it:
###    Section 6. Trademarks. is deleted and replaced with:
###
###    6. Trademarks. This License does not grant permission to use the trade
###       names, trademarks, service marks, or product names of the Licensor
###       and its affiliates, except as required to comply with Section 4(c) of
###       the License and to reproduce the content of the NOTICE file.
###
###    You may obtain a copy of the Apache License at
###
###        http://www.apache.org/licenses/LICENSE-2.0
###
###    Unless required by applicable law or agreed to in writing, software
###    distributed under the Apache License with the above modification is
###    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
###    KIND, either express or implied. See the Apache License for the specific
###    language governing permissions and limitations under the Apache License.
###
###

module JSSWebHooks

  # Event Objects are JSON structures that come from the JSS
  # with every webhook event. They represent the object that was affected
  # by the event. For example, A ComputerAdded event affects
  # a computer, and a RestAPIOperation event affects a REST API
  # object.
  #
  # Since these Event Objects are mostly just short-lived static data
  # they don't need to be represented full-blown Classes, but they would
  # be nicer to work with if they weren't just Hashes.
  #
  # Ruby's Struct class provides a handy way to create something that's
  # more than a Hash but less than a full Class.  Unfortuantely, Struct-
  # derived classes are fully mutable, and require positional parameters
  # when creating instances.
  #
  # The ImmutableStruct class, provided by the immutable-struct gem,
  # (https://github.com/stitchfix/immutable-struct)
  # creates classes whose instances have immutable attributes, but allow
  # (nay, require) named parameters when creating instances.
  #
  # This module dynamically creates ImmutableStruct classes for the various
  # Event Objects that come with each webhook event. Each Event Objects class
  # is defined in the @object_definitions Hash, which is accessible via the
  # JSSWebHooks::EventObjects::object_definitions method.
  #
  # Each object is defined in that Hash thus:
  #
  #   Key:  Symbol, the name of the object e.g. :computer
  #   Value: Hash, the attributes and other data for created the object's Class
  #
  # The value hash has these keys:
  #
  #   :class_name => String, the name of the ImmutableStruct Class for this
  #      object, e.g. "Computer"
  #   :attributes => Array[<Symbol>], The instance-attributes for the Class, to
  #      be passed in as the keys of a hash when creating an instance.
  #   :methods => Array[<Hash>], if any methods are needed for the Class, other
  #      than the default getters for the attributes, each Hash in this array
  #      defines one. The :name key contains a symbol, the name of the method,
  #      and the :proc key contains a Proc object, the method code. See
  #      JSSWebHooks::EventObjects.object_definitions[:patch_software_title_update]
  #      for an example.
  #
  module EventObjects

    # This will hold the object definitions for each Event Object
    # it will be populated by the require statements below.
    @object_definitions = {}

    # Access to the Module-instance var @object_definitions
    #
    # @return [Hash] the @object_definitions Hash
    #
    def self.object_definitions
      @object_definitions
    end

    # load in the definitions of the Event Objects
    Pathname.new(__FILE__).parent.+('event_objects').children.each do |file|
      require file.to_s if file.extname == '.rb'
    end

    # loop thru the event object definitions,
    # creating a class for each, via ImmutableStruct
    @object_definitions.each do |_object_key, object_def|
      new_class = ImmutableStruct.new(*object_def[:attributes]) do
        # Class Method to return the list of attributes for this class
        @attributes = object_def[:attributes]
        def self.attributes
          @attributes
        end

        # if any non-getter methods are needed for this class,
        # create them here
        object_def[:methods].to_a.each do |meth|
          next unless meth[:name] && meth[:proc]
          define_method meth[:name], meth[:proc]
        end
      end
      const_set object_def[:class_name], new_class
    end # @object_definitions.each

  end # module event object

end # module
