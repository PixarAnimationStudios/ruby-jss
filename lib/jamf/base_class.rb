# Copyright 2022 Pixar
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

  # This mixin should be extended in base class definitions
  # it will raise an error if those classes are instantiated or allocated
  # It also maintains an array of classes that extend themselves this way
  #
  module BaseClass

    DEFAULT_ACTION =  'access the API'.freeze
    ALLOCATION_ACTION = 'be allocated'.freeze
    INSTANTIATION_ACTION = 'be instantiated'.freeze

    # when a class is extended by this module, it
    # gets added to the array of known base classes
    def self.extended(by_class)
      base_classes << by_class
    end

    # Classes will be added to this array as they are exteded by BaseClass
    def self.base_classes
      @base_classes ||= []
    end

    # raise an exception if a given class is a base class
    def self.stop_if_base_class(klass, action = DEFAULT_ACTION)
      raise Jamf::UnsupportedError, "#{klass} is a base class and cannot #{action}." if base_classes.include? klass
    end

    def base_class?
      Jamf::BaseClass.base_classes.include? self
    end

    # # Can't allocate if base class
    # def allocate(*args, **kwargs, &block)
    #   stop_if_base_class ALLOCATION_ACTION
    #   super
    # end

    # Can't instantiate if base_class
    def new(*args, **kwargs, &block)
      stop_if_base_class INSTANTIATION_ACTION
      super(*args, **kwargs, &block)
    end

    # raise an exception if this class is a base class
    def stop_if_base_class(action = DEFAULT_ACTION)
      Jamf::BaseClass.stop_if_base_class self, action
    end

  end # module BaseClass

end # Jamf
