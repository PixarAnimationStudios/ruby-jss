### Copyright 2018 Pixar

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

############################################
### Some handy additions to the Pathname class.
### Why aren't they there already?
###
class Pathname
  
  ### Is this a real file rather than a symlink?
  ### @see FileTest.real_file
  def jss_real_file?
    FileTest.jss_real_file? self 
  end # real_file?
  
  ### Copy a path to a destination
  ### @see FileUtils.cp
  def jss_cp(dest, options = {})
    FileUtils.cp @path, dest.to_s, options
  end # cp
  
  ### Recursively copy this path to a destination
  ### @see FileUtils.cp_r
  def jss_cp_r(dest, options = {})
    FileUtils.cp_r @path, dest.to_s, options
  end # cp
  
  ### Write some string content to a file.
  ###
  ### Simpler than always using an open('w') block 
  ### *CAUTION* this overwrites files!
  ###
  def jss_save(content)
    self.open('w'){|f| f.write content.to_s}
  end
  
  ### Append some string content to a file.
  ###
  ### Simpler than always using an open('a') block
  ###
  def jss_append(content)
    self.open('a'){|f| f.write content.to_s}
  end

  ### Touching can be good 
  ###
  ### @see FileUtils.touch
  def jss_touch
    FileUtils.touch @path
  end
  
  ### Pathname should use FileUtils.chown, not File.chown
  def jss_chown(u,g)
    FileUtils.chown u, g, @path
  end
end # class Pathname
