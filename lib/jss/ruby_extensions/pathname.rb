#############################################
### Some handy additions to the Pathname class.
### Why aren't they there already?
###
class Pathname
  
  ### Is this a real file rather than a symlink?
  ### @see FileTest.real_file
  def real_file?
    FileTest.real_file? self 
  end # real_file?
  
  ### Copy a path to a destination
  ### @see FileUtils.cp
  def cp(dest, options = {})
    FileUtils.cp @path, dest.to_s, options
  end # cp
  
  ### Recursively copy this path to a destination
  ### @see FileUtils.cp_r
  def cp_r(dest, options = {})
    FileUtils.cp_r @path, dest.to_s, options
  end # cp
  
  ### Write some string content to a file.
  ###
  ### Simpler than always using an open('w') block 
  ### *CAUTION* this overwrites files!
  ###
  def save(content)
    self.open('w'){|f| f.write content.to_s}
  end
  
  ### Append some string content to a file.
  ###
  ### Simpler than always using an open('a') block
  ###
  def append(content)
    self.open('a'){|f| f.write content.to_s}
  end

  ### Touching can be good 
  ###
  ### @see FileUtils.touch
  def touch
    FileUtils.touch @path
  end
  
  ### Pathname should use FileUtils.chown, not File.chown
  def chown(u,g)
    FileUtils.chown u, g, @path
  end
end # class Pathname
