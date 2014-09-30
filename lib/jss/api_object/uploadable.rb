module JSS

  #####################################
  ### Module Variables
  #####################################


  #####################################
  ### Module Methods
  #####################################

  #####################################
  ### Sub-Modules
  #####################################

  ###
  ### A mixin module providing file-upload capabilities to JSSAPIObject subclasses.
  ###
  ### Classes mixing in this module are required to define a constant UPLOAD_TYPES
  ### which is a Hash of :type => :resource pairs, like this:
  ###
  ###  UPLOAD_TYPES = {
  ###     :icon => :mobiledeviceapplicationsicon
  ###     :app => mobiledeviceapplicationsipa
  ###     :attachment => mobiledeviceapplications
  ###   }
  ###
  ### with one pair for each type of upload that the class can handle.
  ### (most of them only handle one, usually :attachment)
  ###
  ### When the #upload method is called, one of the keys from that Hash must be specified
  ###
  ### Classes with only one upload type may want to redefine #upload to always call super with
  ### that one type.
  ###
  ### ----
  ###
  ### Implementation Notes from
  ### https://casperserver:8443/api/index.htm#!/fileuploads/uploadFiles_post
  ###
  ###   POST ...JSSResource/fileuploads/<resource>/<idType>/<id>
  ###
  ### You can POST different types of files by entering parameters for <resource>, <idType>, and <id>.
  ### For example /JSSResource/fileuploads/computers/id/2.
  ###
  ### Attachments can be uploaded by specifying computers, mobiledevices, enrollmentprofiles, or
  ### peripherals as the resource.
  ###
  ### Icons can be uploaded by specifying policies, ebooks, or mobiledeviceapplicationsicon as the resource.
  ###
  ### A mobile device application can be uploaded by using mobiledeviceapplicationsipa as the resource.
  ###
  ### A disk encryption can be uploaded by specifying diskencryptionconfigurations as the resource.
  ###
  ### idTypes supported are "id" and "name", although peripheral names are not supported.
  ###
  ### A sample command is:
  ###   curl -k -u user:password https://my.jss:8443/JSSResource/fileuploads/computers/id/2 -F name=@/Users/admin/Documents/Sample.doc -X POST
  ###
  ###
  ###
  ###
  module Uploadable

    #####################################
    ###  Constants
    #####################################

    UPLOAD_RSRC_PREFIX = "fileuploads"

    #####################################
    ###  Variables
    #####################################


    #####################################
    ###  Methods
    #####################################

    ###
    ### Upload a file to the JSS via the REST Resource of the
    ### object to which this module is mixed in.
    ###
    ### @param type[Symbol] the type of upload happening.
    ###   Must be one of the keys defined in the class's UPLOAD_TYPES Hash.
    ###
    ### @param local_file[String, Pathname] String or Pathname pointing to the
    ###   locally-readable file to be uploaded.
    ###
    ### @return [String] The xml response from the server.
    ###
    def upload(type, local_file)

      ### the thing's gotta be in the JSS, and have an @id
      raise JSS::NoSuchItemError, 'Create this #{self.class::RSRC_OBJECT_KEY} in the JSS before uploading files to it.' unless @id and @in_jss

      ### the type has to be defined in the class of self.
      raise JSS::InvalidDataError, "#{self.class::RSRC_LIST_KEY} only take uploads of type: :#{self.class::UPLOAD_TYPES.keys.join(', :')}." unless self.class::UPLOAD_TYPES.keys.include? type

      ### figure out the resource after the UPLOAD_RSRC_PREFIX
      upload_rsrc = "#{UPLOAD_RSRC_PREFIX}/#{self.class::UPLOAD_TYPES[type]}/id/#{@id}"

      ### make a File object to hand to REST.
      file = File.new local_file.to_s, 'rb'

      ### upload it!
      JSS::API.cnx[upload_rsrc].post :name => file

    end # def upload file

  end # module FileUpload

end # module JSS
