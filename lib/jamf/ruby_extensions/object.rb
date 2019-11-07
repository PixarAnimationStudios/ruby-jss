# Extensions to Ruby Objects for use within the JSS module
class Object

  # is an object an explict true or false?
  #
  # TODO: globally replace
  #      `JSS::TRUE_FALSE.include? xxx`
  #   with
  #      `xxx.j_boolean?`
  #
  #
  # @return [Boolean]
  #
  def j_boolean?
    [true, false].include? self
  end
  alias j_bool? j_boolean?

end
