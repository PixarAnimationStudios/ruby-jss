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

#
class Hash

  #
  # Convert Hash values to nil.
  #
  # With no block, values equalling the String, or any member of the Array, given
  # will be converted to nil. Equality is evaluated with == and Array#include?
  #
  # With a block, if the result of the block evaluates to true, the value is converted to nil.
  #
  # Subhashes are ignored unless recurse is true.
  #
  # @param to_nils[String,Array] Hash values equal to (==) these become nil. Defaults to empty string
  #
  # @param recurse[Boolean] should sub-Hashes be nillified?
  #
  # @yield [value] Hash values for which the block returns true will become nil.
  #
  # @return [Hash] the hash with the desired values converted to nil
  #
  # @example
  #   hash = {:foo => '', :bar => {:baz => '' }}
  #   hash.jss_nillify!  # {:foo => nil, :bar => {:baz => '' }}
  #
  #   hash = {:foo => '', :bar => {:baz => '' }}
  #   hash.jss_nillify! '', :recurse  # {:foo => nil, :bar => {:baz => nil }}
  #
  #   hash = {:foo => 123, :bar => {:baz => '', :bim => "123" }}
  #   hash.jss_nillify! ['', 123], :recurse # {:foo => nil, :bar => {:baz => nil, :bim => "123" }}
  #
  #   hash = {:foo => 123, :bar => {:baz => '', :bim => "123" }}
  #   hash.jss_nillify!(:anything, :recurse){|v| v.to_i == 123 }  # {:foo => nil, :bar => {:baz => '', :bim => nil }}
  #
  def jss_nillify!(to_nils = '', recurse = false, &block)
    nillify_these = [] << to_nils
    nillify_these.flatten!

    each_pair do |k, v|
      if v.class == Hash
        v.jss_nillify!(to_nils, recurse, &block)
        next
      end
      do_it =
        if block_given?
          yield v
        else
          nillify_these.include? v
        end
      self[k] = nil if do_it
    end # each pair
  end # def nillify

  # Since a lot of JSON data from the API comes as deeply-nested structures
  # of Hashes and Arrays, it can be a pain to reference some of the deeper
  # data inside, and it isn't worth coding them out into Class attributes.
  #
  # For example see the 'hardware' subset of a JSS::Computer's API data,
  # which is stored as a Hash in the {JSS::Computer.hardware} attribute.
  #
  # To refer to the percent-full value of one of the machine's drives, you need
  # to use e.g. this:
  #
  #   computer_instance.hardware[:storage].first[:partition][:percentage_full]
  #
  # It would be nice to use method-like chains to access that data,
  # similar to what OpenStruct provides.
  #
  # But, there are two problems with just storing #hardware as an OpenStruct:
  # 1) we'd lose some important Hash methods, like #keys and #values, breaking
  # backward compatibility. 2) OpenStructs only work on the Hash itself, not
  # not it's contents.
  #
  # So to get the best of both worlds, we use the RecursiveOpenStruct gem
  #
  #   https://github.com/aetherknight/recursive-open-struct
  #
  # which subclasses OpenStruct to be recursive.
  #
  # And, instead of replacing the Hash, we'll add a RecursiveOpenStruct version
  # of itself to itself as an attribute.
  #
  # Now, we can access the same data using this:
  #
  #   computer_instance.hardware.jss_ros.storage.first.partition.percentage_full
  #
  # CAVEAT: Treat these as read-only.
  #
  # While the Hashes themselves may be mutable, their use in ruby-jss Classes
  # should be usually be considered read-only - and the RecursiveOpenStruct
  # object created by this method should not be changed. Changes to the Hash
  # or the RecursiveOpenStruct are NOT synced between them
  #
  # This should be fine for the intended uses. Data like Computer#hardware
  # isn't sent back to the JSS via Computer#update, since it must come
  # from a 'recon' anyway. Data that is sent back to the JSS will have
  # setter methods defined in the class or a mixin module (e.g. the
  # Locatable module).
  #
  # Since the data is read-only, why not use the ImmutableStruct gem, used
  # elsewhere in ruby-jss?  Because ImmutableStruct is really for creating
  # fully-fleshed-out read-only classes, with a known set of attributes rather
  # than just giving us a nicer way to access Hash data with arbitrary keys.
  #
  def jss_recursive_ostruct
    @jss_ros ||= RecursiveOpenStruct.new(self, recurse_over_arrays: true)
  end
  alias jss_ros jss_recursive_ostruct

end # class
