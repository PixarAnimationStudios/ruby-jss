### Copyright 2017 Pixar

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

###
class Hash

  ###
  ### Convert Hash values to nil.
  ###
  ### With no block, values equalling the String, or any member of the Array, given
  ### will be converted to nil. Equality is evaluated with == and Array#include?
  ###
  ### With a block, if the result of the block evaluates to true, the value is converted to nil.
  ###
  ### Subhashes are ignored unless recurse is true.
  ###
  ### @param to_nils[String,Array] Hash values equal to (==) these become nil. Defaults to empty string
  ###
  ### @param recurse[Boolean] should sub-Hashes be nillified?
  ###
  ### @yield [value] Hash values for which the block returns true will become nil.
  ###
  ### @return [Hash] the hash with the desired values converted to nil
  ###
  ### @example
  ###   hash = {:foo => '', :bar => {:baz => '' }}
  ###   hash.jss_nillify!  # {:foo => nil, :bar => {:baz => '' }}
  ###
  ###   hash = {:foo => '', :bar => {:baz => '' }}
  ###   hash.jss_nillify! '', :recurse  # {:foo => nil, :bar => {:baz => nil }}
  ###
  ###   hash = {:foo => 123, :bar => {:baz => '', :bim => "123" }}
  ###   hash.jss_nillify! ['', 123], :recurse # {:foo => nil, :bar => {:baz => nil, :bim => "123" }}
  ###
  ###   hash = {:foo => 123, :bar => {:baz => '', :bim => "123" }}
  ###   hash.jss_nillify!(:anything, :recurse){|v| v.to_i == 123 }  # {:foo => nil, :bar => {:baz => '', :bim => nil }}
  ###
  def jss_nillify!(to_nils = '', recurse = false, &block )

    nillify_these = [] << to_nils
    nillify_these.flatten!

    self.each_pair do |k,v|
      if v.class == Hash
        v.jss_nillify!(to_nils, recurse, &block)
        next
      end
      do_it = if block_given?
        yield v
      else
        nillify_these.include? v
      end
      self[k] = nil if do_it
    end # each pair
  end # def nillify
end # class


