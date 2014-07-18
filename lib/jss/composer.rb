module JSS
 module Composer
  
  require 'plist'
  
  #####################################
  ### Constants
  #####################################
  
  ### the apple pkgutil tool
  PKG_UTIL = Pathname.new "/usr/sbin/pkgutil"
  
  ### The location of the cli tool for making .pkgs
  PKGBUILD = Pathname.new "/usr/bin/pkgbuild"
  
  ### the default bundle identifier prefix for pkgs
  PKG_BUNDLE_ID_PFX = 'rubycomposer'
  
  ### Apple's hdiutil for making dmgs
  HDI_UTIL= '/usr/bin/hdiutil'
  
  ###
  ### Make a casper-happy .pkg out of a root folder, permissions are assumed to be correct.
  ### 
  ### All args are required except :bundle_id_prefix, :out_dir and :preserve_ownership
  ###
  ### - :root => '/some/dir/path/'  - the path to the "root folder" representing the root file system of the target install drive
  ### - :name => 'somename' the version-agnostic name of the item being pkgd, e.g. 'filemaker' or 'googlechrome'
  ### - :bundle_id_prefix => 'some.string'  the pkg bundle identifier prefix. e.g. 'org.some.organization' or 'com.pixar.d3'
  ###       defaults to 'rubycomposer'. see 'man pkgbuild' for more info
  ### - :version => 'someversion' the version of the thing being installed
  ### - :revision => someInt  the integer revision of this pkging of this version of the thing
  ### - :out_dir => /some/dir/path  the folder in which the .pkg will be created. Defaults to /Users/Shared
  ### - :preserve_ownership => boolean. If true, the owner/group of the rootpath are preserved. 
  ###     By default, they become the pkgbuild/installer "recommended" (root/wheel or root/admin)
  ###
  ### Returns: the local path to the new .pkg (string), or nil if there was an error running pkgbuild
  ###
  ### When creating the pkg, the name is used to make the pkg identifier "jss.name", which is how the OS
  ### knows about versions of a thing
  ### and the version-revision are used for the pkg version, eg "1.2-2" <br/>
  ### The pkg filename will be name-version-revision.pkg, and the installer "title" will be name-version-revision
  ###
  def mk_pkg(args = {})
    raise NoSuchItemError, "Missing pkgbuild tool. Please make sure you're running 10.8 or later." unless PKGBUILD.executable?

    raise MissingDataError, "Missing :root path for building a .pkg" unless args[:root]
    raise MissingDataError, "Missing :name for building a .pkg" unless args[:name]
    raise MissingDataError, "Missing :version for building a .pkg" unless args[:version]
    raise MissingDataError, "Missing :revision for building a .pkg" unless args[:revision]
    
    args[:out_dir] ||= "/Users/Shared"
    args[:bundle_id_prefix] ||= PKG_BUNDLE_ID_PFX
    
    pkg_filename = "#{args[:name]}-#{args[:version]}-#{args[:revision]}.pkg"
    pkg_vers = "#{args[:version]}-#{args[:revision]}"
    pkg_id = args[:bundle_id_prefix] + "." + args[:name]
    pkg_out = "#{args[:out_dir]}/#{pkg_filename}"
    pkg_ownership = args[:preserve_ownership] ? "preserve" : "recommended"
    
    
    ### first, run 'analyze' to get a 'component plist' in which we can change some settings
    ### for any bundles in the root (bundles like .apps, frameworks, plugins, etc..)
    ###
    ### we edit the settings thus:
    ### BundleOverwriteAction = upgrade, totally replace any version current on disk
    ### BundleIsVersionChecked = false, allow us to install regardless of what version is currently installed
    ### BundleIsRelocatable = false,  if there's a version of this in some other location, Do Not move this one there after installation
    ### BundleHasStrictIdentifier = false, don't care if there's something at the install path with a different bundle id.
    ###
    ### In other words, just install the thing!
    ### (see 'man pkgbuild' for more info)
    ###
    ### If you need different settings, 
    ###
    comp_plist_out = Pathname.new "/tmp/#{PKG_BUNDLE_ID_PFX}-#{pkg_filename}.plist"
    system "#{PKGBUILD} --analyze --root '#{args[:root]}' '#{comp_plist_out}'"
    comp_plist = Plist.parse_xml comp_plist_out.read
    
    ### if the plist is empty, there are no bundles in the pkg
    if comp_plist[0].nil?
      comp_plist_arg = ''
    else
      ### otherwise, edit the bundle dictionaries
      comp_plist.each do |bndl|
        bndl.delete "ChildBundles" if bndl["ChildBundles"]
        bndl["BundleOverwriteAction"] = "upgrade"
        bndl["BundleIsVersionChecked"] = false
        bndl["BundleIsRelocatable"] = false
        bndl["BundleHasStrictIdentifier"] = false
      end
      ### write out the edits
      comp_plist_out.open('w'){|f| f.write comp_plist.to_plist}
      comp_plist_arg = "--component-plist '#{comp_plist_out}'"
    end
    
    ### now build the pkg
    begin
      system "#{PKGBUILD} --identifier '#{pkg_id}' --version '#{pkg_vers}' --ownership #{pkg_ownership} --install-location / --root '#{args[:root]}' #{comp_plist_arg} '#{pkg_out}' "
    
      raise RuntimeError, "There was an error building the .pkg" unless $?.exitstatus == 0
    ensure
      comp_plist_out.delete if comp_plist_out.exist?
    end
    
    return pkg_out
  end # mk_dot_pkg
 
 
  ###
  ### Make a casper-happy .dmg out of a root folder, permissions are assumed to be correct.
  ### All args are required except :out_dir.
  ###
  ### - :root => '/some/dir/path/'  the path to the "root folder" representing the root file system of the target install drive
  ### - :name => 'somename' the version-agnostic name of the item being pkgd, e.g. 'filemaker' or 'googlechrome'
  ### - :version => 'someversion' the version of the thing being installed
  ### - :revision => someInt  the integer revision of this pkging of this version of the thing
  ### - :out_dir => /some/dir/path  the folder in which the .pkg will be created. Defaults to /Users/Shared
  ###
  ### Returns: the local path to the new .dmg (string), nil if there was an error running hdiutil.
  ###
  ### When creating the dmg, the dmg filename will be name-version-revision.dmg,
  ### and the mounted volume name will be name-version-revision
  ###
  
  def mk_dmg(args = {})
    raise MissingDataError, "Missing :root path for building a .dmg" unless args[:root]
    raise MissingDataError, "Missing :name for building a .dmg" unless args[:name]
    raise MissingDataError, "Missing :version for building a .dmg" unless args[:version]
    raise MissingDataError, "Missing :revision for building a .dmg" unless args[:revision]
    
    args[:out_dir] = "/Users/Shared" unless args[:out_dir]
     
    dmg_filename = "#{args[:name]}-#{args[:version]}-#{args[:revision]}.dmg"
    dmg_vol = "#{args[:name]}-#{args[:version]}-#{args[:revision]}"
    dmg_out = "#{args[:out_dir]}/#{dmg_filename}"
    
    PixJSS.sudo_run "#{HDI_UTIL} create -volname '#{dmg_vol}' -srcfolder '#{args[:root]}' '#{dmg_out}'"
    
    raise RuntimeError, "There was an error building the .dmg" unless $?.exitstatus == 0
    return dmg_out
    
  end # mk_dmg
  
 
 end # module Composer
end # module JSS
  

