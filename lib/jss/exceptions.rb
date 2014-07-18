module JSS
  
  #####################################
  ### Exceptions
  #####################################
  
  ### 
  ### MissingDataError - raise this error when we 
  ### are missing args, or other simliar stuff.
  ### 
  class MissingDataError < RuntimeError; end
  
  ### 
  ### InvalidDataError - raise this error when 
  ### a data item isn't what we expected.
  ### 
  class InvalidDataError < RuntimeError; end
  
  ### 
  ### InvalidConnectionError - raise this error when we 
  ### don't have a usable connection to a network service, or
  ### don't have proper authentication/authorization.
  ### 
  class InvalidConnectionError < RuntimeError; end
  
  ### 
  ### NoSuchItemError - raise this error when 
  ### a desired item doesn't exist.
  ### 
  class NoSuchItemError < RuntimeError; end
  
  ### 
  ### AlreadyExistsError - raise this error when 
  ### trying to create something that already exists.
  ### 
  class AlreadyExistsError < RuntimeError; end
  
  ### 
  ### FileServiceError - raise this error when 
  ### there's a problem accessing file service on a
  ### distribution point.
  ### 
  class FileServiceError < RuntimeError; end
  
  ###
  ### UnmanagedError - raise this when we 
  ### try to do something managerial to 
  ### an unmanaged object
  ###
  class UnmanagedError <  RuntimeError; end
  
  ###
  ### UnsupportedError - raise this when we 
  ### try to do something not yet supported
  ###
  class UnsupportedError <  RuntimeError; end
  
end # module JSS
