# = site_settings.rb
#
# Author:: Chris Lasell, Pixar Animation Studios (mailto:chrisl@pixar.com)
# Copyright:: Copyright (c) 2013 Pixar Animation Studios
#
# Site-specific values for using this JSS module
#

module PixJSS
  
  #####################################
  # Constants
  #####################################
  
  ###
  ### Server access
  ###
  JSS_HOST = "casper.pixar.com"
  JSS_PORT = "9006"
  JSS_SSL_PORT = "8443"
  
  ###
  ### REST access
  ###
  # The default, read-only, username for the REST API
  REST_READER = "restreader"
  
  # The password for the default REST API username
  REST_READER_PW = "rr"
  
  # Kennel is a web service that allows us to make changes to the jss
  # outside of running recons. Used, among other thigns, for adding/removing
  # machines to/from the static group that's scoped for running puppies at
  # logout
  KENNEL_HOST = "kennel.pixar.com"
  KENNEL_PORT = 8080
  
  ###
  ### Paths & Executables
  ###
    
  # The CasperShare folder holds all the scripts, pkgs, etc on the server
  # CasperAdmin.app, and the jamf binary access it via AFP and/or HTTP
  # d3 ad d3admin will access it via NFS and/or HTTP
  # Users needing to access it via d3admin must be in the 'd3admins' group on the 
  # server  
  CSHARE = "CasperShare"
  
  # The location of the CasperShare folder on the server, so 
  # we can mount it via NFS
  CSHARE_SVR_PATH = (Pathname.new "/Volumes/CasperData/#{CSHARE}")
  
  # The mount point for NFS mounting the CasperShare volume, for adding
  # renaming, and deleteing pkgs and scripts
  CASPERSHARE_MNTPNT = Pathname.new "/Volumes/PixarCasperShare"
  
  # The path of the auth. data for the read-write connection to the mysql db
  # This is read by NFS mounting the caspershare volume after the user has authenticated
  # to the JSS via REST - it's only readable by members of the d3 admins group on the casper server
  # 
  # see also the jss_authenticate method
  DB_RW_AUTH_PATH = CASPERSHARE_MNTPNT + "Casper Data/d3_access"
  
  # where we keep pixar-specific casper/jamf-related stuff
  # on client hard drives
  PIXAR_CASPER_DIR = Pixar::LIBADM + "casper"
  
  # the default recon options, with data from ldap
  # kept up to date daily by the ldap2jss script
  PIXAR_RECON_OPTS = PIXAR_CASPER_DIR + "ldap2jss_lastdata"
  
  ###
  ### Other site-specific values
  ###
  
  # the management acct we use on managed machines
  # see the PixJSS variables for the password
  MGMT_ACCT="macadmin"
  
  
  #####################################
  # Module Methods
  #####################################
  
  # get the info in the pixar jss pkg
  def pixar_jss
    tt = PixJSS::HTTP_PKGS_URL + "/do_not_delete.txt"
    hash = {}
    `curl -s '#{tt}'`.lines.map{|a| a.chomp.split(":")}.each{|l| hash[l[0]] = l[1]}
    hash
  end
  
end # module pixjss