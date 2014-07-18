#############################################
### Some handy additions to Pathname
### Why aren't they there already?
###
class Pathname
  
  ### see FileTest.real_file in pixar.rb
  def real_file?
    FileTest.real_file? self 
  end # real_file?
  
  ### see FileUtils.cp
  def cp(dest, options = {})
    FileUtils.cp @path, dest.to_s, options
  end # cp
  
  ### see FileUtils.cp_r
  def cp_r(dest, options = {})
    FileUtils.cp_r @path, dest.to_s, options
  end # cp
  
  ### simpler than always using the open(){write} block
  ### CAUTION: this overwrites files!
  def save(content)
    self.open('w'){|f| f.write content.to_s}
  end
  
  ### simpler than always using the open(){write} block
  def append(content)
    self.open('a'){|f| f.write content.to_s}
  end

  ### touch
  def touch
    FileUtils.touch @path
  end
  
  ### Pathname should use FileUtils.chown, not File.chown
  def chown(u,g)
    FileUtils.chown u, g, @path
  end
end # class Pathname
