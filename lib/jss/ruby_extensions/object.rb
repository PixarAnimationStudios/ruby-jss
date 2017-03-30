# Extensions to Ruby Objects for use within the JSS module
class Object

  # is an object an explict true or false?
  #
  # TODO: globally replace
  #      `JSS::TRUE_FALSE.include? xxx`
  #   with
  #      `xxx.jss_boolean?`
  #
  #
  # @return [Boolean]
  #
  def jss_boolean?
    [true, false].include? self
  end
  alias jss_bool? jss_boolean?

end
