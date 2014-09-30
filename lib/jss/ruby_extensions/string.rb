class String
  
  ### Convert the strings "true" and "false" 
  ### (after stripping whitespace and downcasing)
  ### to TrueClass and FalseClass respectively
  ### 
  ### Return nil if any other string.
  ###
  ### @return [Boolean,nil] the boolean value
  ###
  def to_bool
    case self.strip.downcase
      when "true" then return true
      when "false" then return false
      else return nil
    end # case
  end # to bool
end # class