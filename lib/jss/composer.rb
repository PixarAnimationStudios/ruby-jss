### Copyright 2017 Pixar

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

 ###
 ### This module provides two methods for building very simple Casper-happy .pkg and .dmg packages for deployment.
 ###
 ### Unlike Composer.app from JAMF, this module currently doesn't offer a way to do a before/after disk scan
 ### and use the differences to build the root folder from which the package is built. Nor does the module support
 ### editing the pre/post install scripts in .pkgs.
 ###
 ### The 'root folder', a folder representing the root filesystem of the target machine where the package will be installed,
 ### must already exist and be fully populated and with correct permissions.
 ###
 module Composer



  #####################################
  ### Constants
  #####################################

  ### the apple pkgutil tool
  PKG_UTIL = Pathname.new "/usr/sbin/pkgutil"

  ### The location of the cli tool for making .pkgs
  PKGBUILD = Pathname.new "/usr/bin/pkgbuild"

  ### the default bundle identifier prefix for pkgs
  PKG_BUNDLE_ID_PFX = 'jss_gem_composer'

  ### Apple's hdiutil for making dmgs
  HDI_UTIL= '/usr/bin/hdiutil'

  ### Where to save the output ?
  DEFAULT_OUT_DIR = Pathname.new "/Users/Shared"

  ###
  ### Make a casper-happy .pkg out of a root folder, permissions are assumed to be correct.
  ###
  ### @param name[String] the name of the .pkg. The .pkg suffix will be added if not present
  ###
  ### @param version[String] the version of the .pkg, needed for building the .pkg
  ###
  ### @param root[String, Pathname] the path to the "root folder" representing
  ###   the root file system of the target install drive
  ###
  ### @param opts[Hash] the options for building the .pkg
  ###
  ### @options opts :pkg_id[String] the full package if for the new pkg. 
  ###   e.g. 'com.mycompany.myapp'
  ###
  ### @option opts :bundle_id_prefix[String] the pkg bundle identifier prefix.
  ###   If no :pkg_id is provided, one is made using this prefix and 
  ###   the name provided. e.g. 'com.mycompany' 
  ###   Defaults to '{PKG_BUNDLE_ID_PFX}'. See 'man pkgbuild' for more info
  ###
  ### @option opts :out_dir[String,Pathname] he folder in which the .pkg will be 
  ###   created. Defaults to {DEFAULT_OUT_DIR}
  ###
  ### @option opts :preserve_ownership[Boolean] If true, the owner/group of the 
  ###   rootpath are preserved.
  ###   Default is false: they become the pkgbuild/installer "recommended" 
  ###   (root/wheel or root/admin)
  ###
  ### @return [Pathname] the local path to the new .pkg
  ###
  def self.mk_pkg(name, version, root, opts = {})
    raise NoSuchItemError, "Missing pkgbuild tool. Please make sure you're running 10.8 or later." unless PKGBUILD.executable?

    opts[:out_dir] ||= DEFAULT_OUT_DIR
    opts[:bundle_id_prefix] ||= PKG_BUNDLE_ID_PFX

    pkg_filename = name.end_with?(".pkg") ? name : name+".pkg"
    pkg_id = opts[:pkg_id]
    pkg_id ||= opts[:bundle_id_prefix] + "." + name
    pkg_out = "#{opts[:out_dir]}/#{pkg_filename}"
    pkg_ownership = opts[:preserve_ownership] ? "preserve" : "recommended"


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
    ###
    comp_plist_out = Pathname.new "/tmp/#{PKG_BUNDLE_ID_PFX}-#{pkg_filename}.plist"
    system "#{PKGBUILD} --analyze --root '#{root}' '#{comp_plist_out}'"
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
      system "#{PKGBUILD} --identifier '#{pkg_id}' --version '#{version}' --ownership #{pkg_ownership} --install-location / --root '#{root}' #{comp_plist_arg} '#{pkg_out}' "

      raise RuntimeError, "There was an error building the .pkg" unless $?.exitstatus == 0
    ensure
      comp_plist_out.delete if comp_plist_out.exist?
    end

    return Pathname.new pkg_out
  end # mk_dot_pkg


  ###
  ### Make a casper-happy .dmg out of a root folder, permissions are assumed to be correct.
  ###
  ### @param name[String] The name of the .dmg, the suffix will be added if needed
  ###
  ### @param root[String, Pathname]  the path to the "root folder" representing the root file system of the target install drive
  ###
  ### @param out_dir[String, Pathname] the folder in which the .pkg will be created. Defaults to {DEFAULT_OUT_DIR}
  ###
  ### @return [Pathname] the local path to the new .dmg
  ###
  ###
  def self.mk_dmg(name, root, out_dir = DEFAULT_OUT_DIR)

    dmg_filename = "#{name}.dmg"
    dmg_vol = name
    dmg_out = Pathname.new "#{out_dir}/#{dmg_filename}"
    if dmg_out.exist?
      mv_to = dmg_out.dirname + "#{dmg_out.basename}.#{Time.now.strftime('%Y%m%d%H%M%S')}"
      dmg_out.rename mv_to
    end # if dmg out exist

    ### TODO - this may need to be sudo'd to handle proper internal permissions.
    system "#{HDI_UTIL} create -volname '#{dmg_vol}' -scrub -srcfolder '#{root}' '#{dmg_out}'"

    raise RuntimeError, "There was an error building the .dmg" unless $?.exitstatus == 0
    return Pathname.new dmg_out

  end # mk_dmg


 end # module Composer
end # module JSS


