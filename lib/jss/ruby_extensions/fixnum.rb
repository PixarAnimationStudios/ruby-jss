#############################################
### Convert an integer "epoch" style timestamp from the JSS
### into a ruby DateTime object.
###
class Fixnum
  def to_jss_datetime
    self.to_s.to_jss_datetime
  end
end # Fixnum


