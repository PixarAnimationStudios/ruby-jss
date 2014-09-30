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
  ###   hash.nillify!  # {:foo => nil, :bar => {:baz => '' }}
  ###
  ###   hash = {:foo => '', :bar => {:baz => '' }}
  ###   hash.nillify! '', :recurse  # {:foo => nil, :bar => {:baz => nil }}
  ###
  ###   hash = {:foo => 123, :bar => {:baz => '', :bim => "123" }}
  ###   hash.nillify! ['', 123], :recurse # {:foo => nil, :bar => {:baz => nil, :bim => "123" }}
  ###
  ###   hash = {:foo => 123, :bar => {:baz => '', :bim => "123" }}
  ###   hash.nillify!(:anything, :recurse){|v| v.to_i == 123 }  # {:foo => nil, :bar => {:baz => '', :bim => nil }}
  ###
  def nillify!(to_nils = '', recurse = false, &block )

    nillify_these = [] << to_nils
    nillify_these.flatten!

    self.each_pair do |k,v|
      if v.class == Hash
        v.nillify!(to_nils, recurse, &block)
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


