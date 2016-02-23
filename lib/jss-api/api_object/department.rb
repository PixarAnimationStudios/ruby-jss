### Copyright 2016 Pixar
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
module JSS
  
  #####################################
  ### Module Variables
  #####################################

  #####################################
  ### Module Methods
  #####################################
  
  #####################################
  ### Classes
  #####################################

  ### 
  ### A department in the JSS.
  ### These are simple, in that they only have an ID and a name
  ###
  ### @see JSS::APIObject
  ###
  class Department < JSS::APIObject
    
    #####################################
    ### Mix-Ins
    #####################################
    include JSS::Creatable
    include JSS::Updatable
    
    #####################################
    ### Class Methods
    #####################################

    #####################################
    ### Class Constants
    #####################################
    
    ### The base for REST resources of this class
    RSRC_BASE = "departments"
    
    ### the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :departments
    
    ### The hash key used for the JSON object output.
    ### It's also used in various error messages
    RSRC_OBJECT_KEY = :department
    
    ### these keys, as well as :id and :name,  are present in valid API JSON data for this class
    VALID_DATA_KEYS = []
    
    #####################################
    ### Attributes
    #####################################
    
    #####################################
    ### Constructor 
    #####################################
    
    ###
    ### See JSS::APIObject#initialize
    ###

    #####################################
    ### Public Instance Methods
    #####################################
    
  end # class department
  
end # module
