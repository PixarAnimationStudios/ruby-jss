# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
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
