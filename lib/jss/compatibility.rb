###
### Augmentation to make this code compatible with ruby 1.8.7
###

#############################################
### Hash.key
###
### #key exists in ruby 1.9+, in 1.8 its called #index
### it returns the hash key for a given value, if the value exists
### in the hash
###
unless {}.respond_to? :key
  class Hash
    alias_method  :key, :index
  end
end

#############################################
### Array.sample
###
### #sample exists in ruby 1.9+, in 1.8 its called #choice
### it returns a randomly chosen element of the given array
### eg: [1, 2, 3].sample returns either 1, 2, or 3
###
unless [].respond_to? :sample
  class Array
    alias_method :sample, :choice
  end
end


#############################################
### String.force_encoding
###
### Ruby 1.8 doesn't do encodings...
###
unless "".respond_to? :force_encoding
  class String
    def force_encoding(args = nil); self; end
  end
end
