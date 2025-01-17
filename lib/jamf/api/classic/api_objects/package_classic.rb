# Copyright 2025 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#

# TEMPPORARY
require 'digest'

module Jamf

  # Classes
  #####################################

  # A Package in the JSS
  #
  # Also the API provides no access to the package's
  # file list (index), so indexing must be done separately (usually via Casper Admin)
  #
  class PackageClassic < Jamf::APIObject

    # Mix-Ins
    #####################################

    include Jamf::Categorizable
    include Jamf::Creatable
    include Jamf::Updatable

    # Class Methods
    #####################################

    # Class Constants
    #####################################

    # The base for REST resources of this class
    RSRC_BASE = 'packages'.freeze

    # the hash key used for the JSON list output of all objects in the JSS
    RSRC_LIST_KEY = :packages

    # The hash key used for the JSON object output.
    # It's also used in various error messages
    RSRC_OBJECT_KEY = :package

    # The pkg storage folder on the distribution point
    DIST_POINT_PKGS_FOLDER = 'Packages'.freeze

    # The possible values for cpu_type (required_processor) in a JSS package
    CPU_TYPES = %w[None x86 ppc].freeze

    # the possible priorities
    PRIORITIES = (1..20)

    # the default priority, since one is needed for making new pkgs
    DEFAULT_PRIORITY = 10

    # by default, no processor requirement
    DEFAULT_PROCESSOR = 'None'.freeze

    # When we shouldn't install anything (e.g. switch w/package)
    DO_NOT_INSTALL = 'Do Not Install'.freeze

    # The table in the database for this object
    DB_TABLE = 'packages'.freeze

    # The hash_type value in the API for md5
    CHECKSUM_HASH_TYPE_MD5 = 'MD5'.freeze

    # The hash_type value in the API for sha512
    CHECKSUM_HASH_TYPE_SHA512 = 'SHA_512'.freeze

    # Mapping of the hash types to the maching Digest modules
    # See {#calculate_checksum}
    CHECKSUM_HASH_TYPES = {
      CHECKSUM_HASH_TYPE_MD5 => Digest::MD5,
      CHECKSUM_HASH_TYPE_SHA512 => Digest::SHA512
    }.freeze

    DEFAULT_CHECKSUM_HASH_TYPE = CHECKSUM_HASH_TYPE_SHA512

    # the object type for this object in
    # the object history table.
    # See {APIObject#add_object_history_entry}
    OBJECT_HISTORY_OBJECT_TYPE = 90

    # Where is the Category in the API JSON?
    CATEGORY_SUBSET = :top

    # How is the category stored in the API data?
    CATEGORY_DATA_TYPE = String

    # Class Methods
    #####################################

    # An array of all dist-point filenames used by all JSS packages
    #
    # Slow cuz we have to instantiate every pkg
    #
    # @param cnx [Jamf::Connection] an API connection to use
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Array<String>] The current file names
    #
    def self.all_filenames(api: nil, cnx: Jamf.cnx)
      cnx = api if api
      all_filenames_by(:id, cnx: cnx).values
    end

    # A Hash of all dist-point filenames used by all JSS packages, keyed by
    # package name or id
    #
    # Slow cuz we have to instantiate every pkg
    #
    # @param key[Symbol] either :id, or :name
    #
    # @param cnx [Jamf::Connection] an API connection to use
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @return [Hash{Ingeter,String => String}] The current file names by key
    #
    def self.all_filenames_by(key, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      raise ArgumentError, 'key must be :id or :name' unless %i[id name].include? key

      files_in_use = {}
      all_ids(:refresh, cnx: cnx).each do |pkg_id|
        pkg = fetch id: pkg_id, cnx: cnx
        files_in_use[pkg.send(key)] = pkg.filename
      end

      files_in_use
    end

    # An array of String filenames for all files DIST_POINT_PKGS_FOLDER
    # that aren't used by a Jamf::Package
    #
    # Slow cuz we have to instantiate every pkg
    #
    # @param ro_pw[String] the password for the readonly account
    #  on the master Distribution Point,
    #
    # @param unmount[Boolean] whether or not ot unount the
    #   distribution point when finished.
    #
    # @param cnx [Jamf::Connection] an API connection to use
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @param dist_point [String,Integer] the name or id of the distribution
    #   point to use. Defaults to the Master Dist. Point
    #
    # @return [Array<String>] The orphaned files
    #
    def self.orphaned_files(ro_pw, unmount = true, dist_point: nil, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      dp = fetch_dist_point(dist_point, cnx: cnx)
      pkgs_dir = dp.mount(ro_pw, :ro) + DIST_POINT_PKGS_FOLDER
      files_on_dp = pkgs_dir.children.map { |f| f.basename.to_s }
      dp.unmount if unmount
      files_on_dp - all_filenames(cnx: cnx)
    end

    # An array of String filenames for all filenames in any
    # Jamf::Package that don't exist on DIST_POINT_PKGS_FOLDER
    #
    # Slow cuz we have to instantiate every pkg
    #
    # @param ro_pw[String] the password for the readonly account
    #  on the master Distribution Point,
    #
    # @param unmount[Boolean] whether or not ot unount the
    #   distribution point when finished.
    #
    # @param cnx [Jamf::Connection] an API connection to use
    #   Defaults to the corrently active API. See {Jamf::Connection}
    #
    # @param dist_point [String,Integer] the name or id of the distribution
    #   point to use. Defaults to the Master Dist. Point
    #
    #
    # @return [Array<String>] The orphaned files
    #
    def self.missing_files(ro_pw, unmount = true, dist_point: nil, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      dp = fetch_dist_point(dist_point, cnx: cnx)
      pkgs_dir = dp.mount(ro_pw, :ro) + DIST_POINT_PKGS_FOLDER
      files_on_dp = pkgs_dir.children.map { |f| f.basename.to_s }
      dp.unmount if unmount
      all_filenames(cnx: cnx) - files_on_dp
    end

    # Given a file path, and hash type, generate the checksum for an arbitrary
    # file.
    #
    # @param filepath [String, Pathname] The file to checksum
    #
    # @param type [String ] One of the keys of CHECKSUM_HASH_TYPES, either
    #    CHECKSUM_HASH_TYPE_MD5 or CHECKSUM_HASH_TYPE_SHA512
    #
    # @return [String] The checksum of the file
    #
    def self.calculate_checksum(filepath, type = DEFAULT_CHECKSUM_HASH_TYPE)
      raise ArgumentError, 'Unknown checksum hash type' unless CHECKSUM_HASH_TYPES.key? type

      CHECKSUM_HASH_TYPES[type].file(filepath).hexdigest
    end

    # @param dist_point [String,Integer] the name or id of the distribution
    #   point to use. Defaults to the Master Dist. Point
    #
    # @return [Jamf::DistributionPoint]
    def self.fetch_dist_point(dist_point, api: nil, cnx: Jamf.cnx)
      cnx = api if api

      if dist_point
        Jamf::DistributionPoint.fetch dist_point, cnx: cnx
      else
        Jamf::DistributionPoint.master_distribution_point cnx: cnx
      end
    end

    # Attributes
    #####################################

    # @return [String] the filename of the .pkg, .mpkg, or .dmg on the Casper server
    attr_reader :filename

    # @return [Pathname] the local receipt when this pkg is installed
    attr_reader :receipt

    # @return [Boolean] does this item 'Fill Existing Users' when jamf installs it?
    attr_reader :fill_existing_users

    # @return [Boolean] does this pkg also get install in the OS user homedir template
    attr_reader :fill_user_template

    # @return [Boolean] does this item require a reboot after installation?
    attr_reader :reboot_required

    # @return [Array<String>] the OS versions this can be installed onto. For all minor versions, the format is 10.5.x
    attr_reader :os_requirements

    # @return [String] limit installation to these architectures: 'x86',  'ppc', 'None'
    attr_reader :required_processor

    # @return [String] the name of a pkg to install (or "Do Not Install") when this pkg can't be installed
    attr_reader :switch_with_package

    # @return [Boolean] can this item be uninstalled? Some, e.g. OS Updates, can't
    attr_reader :allow_uninstalled

    # @return [String] the info field for this pkg - stores d3's basename & swupdate values
    attr_reader :info

    # @return [String] the notes field for this pkg
    attr_reader :notes

    # @return [Boolean] only install this pkg if it's available in the commandline softwareupdate.
    attr_reader :install_if_reported_available

    # @return [Boolean] should this pkg be installed on the boot volume during imaging
    attr_reader :boot_volume_required

    # @return [Integer] Priority to use for deploying or uninstalling the package
    attr_reader :priority

    # @return [Boolean] does this pkg cause a notification to be sent on self-heal?
    attr_reader :send_notification

    # @ @return [Symbol] The checksum hash type used to generate the checksum value,
    #  either :md5 or :sha512, defaults to :sha512 if there is no checksum yet.
    attr_reader :checksum_type

    # @return [String, nil] the checksum value for the package file on the
    #   dist. point, if it's been calculated.
    attr_reader :checksum

    # @see Jamf::APIObject#initialize
    #
    def initialize(**args)
      super

      # now we have pkg_data with something in it, so fill out the instance vars
      @allow_uninstalled = @init_data[:allow_uninstalled]
      @boot_volume_required = @init_data[:boot_volume_required]
      @filename = @init_data[:filename] || @init_data[:name]
      @fill_existing_users = @init_data[:fill_existing_users]
      @fill_user_template = @init_data[:fill_user_template]
      @info = @init_data[:info]
      @install_if_reported_available = @init_data[:install_if_reported_available]
      @notes = @init_data[:notes]
      @os_requirements = @init_data[:os_requirements].split(/\s*,\s*/) if @init_data[:os_requirements]
      @os_requirements ||= []

      @priority = @init_data[:priority] || DEFAULT_PRIORITY
      @reboot_required = @init_data[:reboot_required]
      @required_processor = @init_data[:required_processor] || DEFAULT_PROCESSOR
      @required_processor = nil if @required_processor.to_s.casecmp('none').zero?
      @send_notification = @init_data[:send_notification]
      @switch_with_package = @init_data[:switch_with_package] || DO_NOT_INSTALL

      @checksum = @init_data[:hash_value] # ill be nil if no checksum
      @checksum_type = @checksum ? @init_data[:hash_type] : DEFAULT_CHECKSUM_HASH_TYPE

      # the receipt is the filename with any .zip extension removed.
      @receipt = @filename ? (Jamf::Client::RECEIPTS_FOLDER + @filename.to_s.sub(/.zip$/, '')) : nil
    end # init

    # Change the 'allow to be uninstalled' field in the JSS
    # NOTE The package must be indexed before this works. Right now, that means
    # using CasperAdmin.app
    #
    # @param new_val[Boolean]
    #
    # @return [void]
    #
    def allow_uninstalled=(new_val)
      return nil if new_val == @allow_uninstalled

      # removable? defaults to false
      # even though we usually want to be able to ununstall things, it would be
      # dangerous to do on things like OS updates, so it must be turned on explicitly.
      # packages must be indexed with Casper Admin in order to be uninstalled.
      new_val = false if new_val.to_s.empty?
      raise Jamf::InvalidDataError, "allow_uninstalled must be boolean 'true' or 'false'" unless Jamf::TRUE_FALSE.include? new_val

      @allow_uninstalled = new_val
      @need_to_update = true
    end

    # Change the boot volume required field in the JSS
    #
    # @param new_val[Boolean]
    #
    # @return [void]
    #
    def boot_volume_required=(new_val)
      return nil if new_val == @boot_volume_required

      new_val = false if new_val.to_s.empty?
      raise Jamf::InvalidDataError, 'install_if_reported_available must be boolean true or false' unless Jamf::TRUE_FALSE.include? new_val

      @boot_volume_required = new_val
      @need_to_update = true
    end

    # Change the package filename.
    # Setting it to nil or empty will make it match the display name
    #
    # @param new_val[String]
    #
    # @return [void]
    #
    def filename=(new_val)
      new_val = nil if new_val == ''
      new_val ||= @name
      return nil if new_val == @filename

      @filename = new_val
      @need_to_update = true
    end

    # Change the Fill Existing Users value
    #
    # @param new_val[Boolean]
    #
    # @return [void]
    #
    def fill_existing_users=(new_val)
      return nil if new_val == @fill_existing_users

      new_val = false if new_val.to_s.empty?
      raise Jamf::InvalidDataError, "fill_existing_users must be boolean 'true' or 'false'" unless Jamf::TRUE_FALSE.include? new_val

      @fill_existing_users = new_val
      @need_to_update = true
    end

    # Change the fill_user_template value
    #
    # @param new_val[Boolean]
    #
    # @return [void]
    #
    def fill_user_template=(new_val)
      return nil if new_val == @fill_user_template

      new_val = false if new_val.to_s.empty?
      raise Jamf::InvalidDataError, "fill_user_template must be boolean 'true' or 'false'" unless Jamf::TRUE_FALSE.include? new_val

      @fill_user_template = new_val
      @need_to_update = true
    end

    # Change the info field in the JSS.
    #
    # @param new_val[String]
    #
    # @return [void]
    #
    def info=(new_val)
      return nil if new_val == @info

      # line breaks should be \r
      new_val = new_val.to_s.tr("\n", "\r")
      @info = new_val
      @need_to_update = true
    end

    # Change the if_in_swupdate field in the JSS
    #
    # @param new_val[Boolean]
    #
    # @return [void]
    #
    def install_if_reported_available=(new_val)
      return nil if new_val == @install_if_reported_available

      new_val = false if new_val.to_s.empty?
      raise Jamf::InvalidDataError, 'install_if_reported_available must be boolean true or false' unless Jamf::TRUE_FALSE.include? new_val

      @install_if_reported_available = new_val
      @need_to_update = true
    end

    # Change the notes field in the JSS.NewLines are converted \r.
    #
    # @param new_val[String]
    #
    # @return [void]
    #
    def notes=(new_val)
      return nil if new_val == @notes

      # line breaks should be \r
      new_val = new_val.to_s.tr("\n", "\r")
      @notes = new_val
      @need_to_update = true
    end

    # Change the  checksum type
    #
    # @param new_val[String]
    #
    # @return [void]
    #
    def checksum_type=(new_val)
      return if new_val == @checksum_type
      raise Jamf::InvalidDataError, "Checksum type must be one of: #{CHECKSUM_HASH_TYPES.keys.join ', '} " unless CHECKSUM_HASH_TYPES.key? new_val

      @checksum_type = new_val
      @need_to_update = true
    end

    # Change the  checksum type
    #
    # @param new_val[String]
    #
    # @return [void]
    #
    def checksum=(new_val)
      return if new_val == @checksum
      raise Jamf::InvalidDataError, 'Checksum must be a String or nil' unless new_val.is_a?(String) || new_val.nil?

      @checksum = new_val
      @need_to_update = true
    end

    # Change the os_requirements field in the JSS
    # E.g. 10.5, 10.5.3, 10.6.x
    #
    # @param new_val[String,Array] comma-separated string, or array of os versions
    #
    # @return [void]
    #
    # Extra feature: Minumum OS's can now be specified as a
    # string using the notation ">=10.6.7".
    #
    # @see JSS.expand_min_os
    #
    def os_requirements=(new_val)
      # nil should be an empty array
      new_val = [] if new_val.to_s.empty?

      # if any value starts with >=, expand it
      case new_val
      when String
        new_val = JSS.expand_min_os(new_val) if new_val =~ /^>=/
      when Array
        new_val.map! { |a| a =~ /^>=/ ? JSS.expand_min_os(a) : a }
        new_val.flatten!
        new_val.uniq!
      else
        raise Jamf::InvalidDataError, 'os_requirements must be a String or an Array of strings'
      end
      # get the array version
      @os_requirements = JSS.to_s_and_a(new_val)[:arrayform]
      @need_to_update = true
    end

    # Is a given OS OK for this package based on its
    # @os_requirements?
    #
    # @param os[String] the os to check, defaults to
    #  the os of the current machine.
    #
    # @return [Boolean] can this pkg be installed with the os
    #   given?
    #
    def os_ok?(os = nil)
      JSS.os_ok? @os_requirements, os
    end

    # Change the priority field in the JSS
    #
    # @param new_val[Integer] one of PRIORITIES
    #
    # @return [void]
    #
    def priority=(new_val)
      return nil if new_val == @priority

      new_val = DEFAULT_PRIORITY if new_val.to_s.empty?
      raise Jamf::InvalidDataError, ':priority must be an integer from 1-20' unless PRIORITIES.include? new_val

      @priority = new_val
      @need_to_update = true
    end

    # Change the reboot-required field in the JSS
    #
    # @param new_val[Boolean]
    #
    # @return [void]
    #
    def reboot_required=(new_val)
      return nil if new_val == @reboot_required

      new_val = false if new_val.to_s.empty?
      raise Jamf::InvalidDataError, "reboot must be boolean 'true' or 'false'" unless Jamf::TRUE_FALSE.include? new_val

      @reboot_required = new_val
      @need_to_update = true
    end

    # Change the required processor field in the JSS
    #
    # @param new_val[String] one of {CPU_TYPES}
    #
    # @return [void]
    #
    def required_processor=(new_val)
      return nil if new_val == @required_processor

      new_val = DEFAULT_PROCESSOR if new_val.to_s.empty?
      raise Jamf::InvalidDataError, "Required_processor must be one of: #{CPU_TYPES.join ', '}" unless CPU_TYPES.include? new_val

      @required_processor = new_val
      @need_to_update = true
    end

    # Is a given processor OK for this package based on its
    # @required_processor?
    #
    # @param processor[String] the processor to check, defaults to
    #  the processor of the current machine.
    #
    # @return [Boolean] can this pkg be installed with the processor
    #   given?
    #
    def processor_ok?(processor = nil)
      JSS.processor_ok? @required_processor, processor
    end

    # Change the notify field in the JSS
    #
    # @param new_val[Boolean]
    #
    # @return [void]
    #
    def send_notification=(new_val)
      return nil if new_val == @send_notification

      new_val = false if new_val.to_s.empty?
      raise Jamf::InvalidDataError, 'send_notification must be boolean true or false' unless Jamf::TRUE_FALSE.include? new_val

      @send_notification = new_val
      @need_to_update = true
    end

    # Change which pkg should be installed if this one can't.
    #
    # @param new_val[String] the name of an existing package or "Do Not Install"
    #
    # @return [void]
    #
    def switch_with_package=(new_val)
      return nil if new_val == @switch_with_package

      new_val = nil if new_val.to_s.empty?

      raise Jamf::NoSuchItemError, "No package named '#{new_val}' exists in the JSS" if new_val && (!self.class.all_names(cnx: @cnx).include? new_val)

      new_val ||= DO_NOT_INSTALL
      @switch_with_package = new_val
      @need_to_update = true
    end

    # Is this packaged installed on the current machine (via casper)?
    # We just look for the receipt, which is the @filename less any possible .zip extension.
    #
    # @return [Boolean]
    #
    def installed?
      @receipt.file?
    end

    # Upload a locally-readable file to the master distribution point.
    # If the file is a directory (like a bundle .pk/.mpkg) it will be zipped before
    # uploading and the @filename will be adjusted accordingly by adding a .zip extension
    #
    # The name of the local file doesn't matter, the file on the dist. point will
    # use the @filename (possibly with .zip)
    #
    # If you'll be uploading several files you can specify unmount as false, and do it manually when all
    # are finished with Jamf::DistributionPoint.master_distribution_point.unmount
    #
    # @param local_file_path[String,Pathname] the local path to the file to be uploaded
    #
    # @param rw_pw[String,Symbol] the password for the read/write account on the master Distribution Point,
    #   or :prompt, or :stdin# where # is the line of stdin containing the password See {Jamf::DistributionPoint#mount}
    #
    # @param unmount[Boolean] whether or not ot unount the distribution point when finished.
    #
    # @param chksum [String] the constants CHECKSUM_HASH_TYPE_SHA512 or
    #   CHECKSUM_HASH_TYPE_MD5. Anything else means don't calc.
    #
    # @param dist_point [String,Integer] the name or id of the distribution
    #   point to use. Defaults to the Master Dist. Point
    #
    # @return [void]
    #
    def upload_master_file(local_file_path, rw_pw, unmount = true, chksum: DEFAULT_CHECKSUM_HASH_TYPE, dist_point: nil)
      raise Jamf::NoSuchItemError, 'Please create this package in the JSS before uploading it.' unless @in_jss

      dp = self.class.fetch_dist_point(dist_point, cnx: @cnx)

      destination = dp.mount(rw_pw, :rw) + "#{DIST_POINT_PKGS_FOLDER}/#{@filename}"

      local_path = Pathname.new local_file_path
      raise Jamf::NoSuchItemError, "Local file '#{@local_file}' doesn't exist" unless local_path.exist?

      # should we zip it?
      if local_path.directory?
        begin
          # go to the same dir as the local file
          wd = Dir.pwd
          Dir.chdir local_path.parent

          # the contents of the zip file have to have the same name as the zip file itself (minus the .zip)
          # so temporarily rename the source
          local_path_to_upload = local_path.parent + @filename
          local_path.rename local_path_to_upload unless local_path_to_upload == local_path

          zipdir = Pathname.new "/tmp/rubyjsstmp-#{Time.new.strftime '%Y%m%d%H%M%S'}-#{$PROCESS_ID}"
          zipdir.mkpath
          zipdir.chmod 0o700
          zipfile = zipdir + (local_path_to_upload.basename.to_s + '.zip')

          raise 'There was a problem zipping the pkg bundle' unless system "/usr/bin/zip -qr '#{zipfile}' '#{local_path_to_upload}'"
        ensure
          # rename the source to the original name
          local_path_to_upload.rename local_path if local_path_to_upload.exist? && local_path_to_upload != local_path
          # go back where we started
          Dir.chdir wd
        end # begin

        # update our info
        local_path = zipfile
        destination = destination.to_s + '.zip'
        @filename = zipfile.basename.to_s
        @need_to_update = true
      end # if directory

      FileUtils.copy_entry local_path, destination

      if CHECKSUM_HASH_TYPES.keys.include? chksum
        @checksum_type = chksum
        @checksum = calculate_checksum local_file: local_path, type: chksum, unmount: false, dist_point: dist_point
        @need_to_update = true
      end
      update if @need_to_update
      dp.unmount if unmount
    end # upload master file

    # Using either a local file, or the file on the master dist. point,
    # re-set the checksum for this package. Call #update to save the
    # new one to the JSS.
    #
    # BE VERY CAREFUL if using a local copy of the file - make sure its
    # identical to the one on the dist point.
    #
    # This can be used to change the checksum type, and by default will use
    # DEFAULT_CHECKSUM_HASH_TYPE ('SHA_512')
    #
    # @param @see calculate_checksum
    #
    # @return [void]
    #
    def reset_checksum(type: nil, local_file: nil, rw_pw: nil, ro_pw: nil, unmount: true, dist_point: nil)
      type ||= DEFAULT_CHECKSUM_HASH_TYPE

      new_checksum = calculate_checksum(
        type: type,
        local_file: local_file,
        rw_pw: rw_pw,
        ro_pw: ro_pw,
        unmount: unmount,
        dist_point: dist_point
      )
      return if @checksum == new_checksum

      @checksum_type = type
      @checksum = new_checksum
      @need_to_update = true
    end

    # Caclulate and return the checksum hash for a given local file, or the file
    # on the master dist point if no local file is given.
    #
    # @param type [String] The checksum hash type, one of the keys of
    #   CHECKSUM_HASH_TYPES
    #
    # @param local_file [String, Pathname] A local copy of the pkg file. BE SURE
    #   it's identical to the one on the server. If omitted, the master dist.
    #   point will be mounted and the file read from there.
    #
    # @param rw_pw [String] The read-write password for mounting the master dist
    #   point. Either this or the ro_pw must be provided if no local_file
    #
    # @param ro_pw [String] The read-onlypassword for mounting the master dist
    #   point. Either this or the rw_pw must be provided if no local_file
    #
    # @param unmount [Boolean] Unmount the master dist point after using it.
    #   Only used if the dist point is mounted. default: true
    #
    # @param dist_point [String,Integer] the name or id of the distribution
    #   point to use. Defaults to the Master Dist. Point
    #
    # @return [String] The calculated checksum
    #
    def calculate_checksum(type: nil, local_file: nil, rw_pw: nil, ro_pw: nil, unmount: true, dist_point: nil)
      type ||= DEFAULT_CHECKSUM_HASH_TYPE
      dp = self.class.fetch_dist_point(dist_point, cnx: @cnx)

      if local_file
        file_to_calc = local_file
      else
        if rw_pw
          dppw = rw_pw
          mnt = :rw
        elsif ro_pw
          dppw = ro_pw
          mnt = :ro
        else
          raise ArgumentError, 'Either rw_pw: or ro_pw: must be provided'
        end
        file_to_calc = dp.mount(dppw, mnt) + "#{DIST_POINT_PKGS_FOLDER}/#{@filename}"
      end
      new_checksum = self.class.calculate_checksum(file_to_calc, type)
      dp.unmount if unmount && dp.mounted?
      new_checksum
    end

    # Is the checksum for this pkg is valid?
    #
    # @param local_file [String, Pathname] A local copy of the pkg file. BE SURE
    #   it's identical to the one on the server. If omitted, the master dist.
    #   point will be mounted and the file read from there.
    #
    # @param rw_pw [String] The read-write password for mounting the master dist
    #   point. Either this or the ro_pw must be provided if no local_file
    #
    # @param ro_pw [String] The read-onlypassword for mounting the master dist
    #   point. Either this or the rw_pw must be provided if no local_file
    #
    # @param unmount [Boolean] Unmount the master dist point after using it.
    #   Only used if the dist point is mounted. default: true
    #
    # @param dist_point [String,Integer] the name or id of the distribution
    #   point to use. Defaults to the Master Dist. Point
    #
    # @return [Boolean] false if there is no checksum for this pkg, otherwise,
    #   does the calculated checksum match the one stored for the pkg?
    #
    def checksum_valid?(local_file: nil, rw_pw: nil, ro_pw: nil, unmount: true, dist_point: nil)
      return false unless @checksum

      new_checksum = calculate_checksum(
        type: @checksum_type,
        local_file: local_file,
        rw_pw: rw_pw,
        ro_pw: ro_pw,
        unmount: unmount,
        dist_point: dist_point
      )
      new_checksum == @checksum
    end

    # Change the name of a package file on the master distribution point.
    #
    # @param new_file_name[String]
    #
    # @param old_file_name[default: @filename, String]
    #
    # @param unmount[Boolean] whether or not ot unount the distribution point when finished.
    #
    # @param rw_pw[String,Symbol] the password for the read/write account on the master Distribution Point,
    #   or :prompt, or :stdin# where # is the line of stdin containing the password See {Jamf::DistributionPoint#mount}
    #
    # @param dist_point [String,Integer] the name or id of the distribution
    #   point to use. Defaults to the Master Dist. Point
    #
    # @return [nil]
    #
    def update_master_filename(old_file_name, new_file_name, rw_pw, unmount = true, dist_point: nil)
      raise Jamf::NoSuchItemError, "#{old_file_name} does not exist in the jss." unless @in_jss

      dp = self.class.fetch_dist_point(dist_point, cnx: @cnx)

      pkgs_dir = dp.mount(rw_pw, :rw) + DIST_POINT_PKGS_FOLDER.to_s
      old_file = pkgs_dir + old_file_name
      raise Jamf::NoSuchItemError, "File not found on the master distribution point at #{DIST_POINT_PKGS_FOLDER}/#{old_file_name}." unless \
        old_file.exist?

      new_file = pkgs_dir + new_file_name
      # use the extension of the original file.
      new_file = pkgs_dir + (new_file_name + old_file.extname) if new_file.extname.empty?

      old_file.rename new_file
      dp.unmount if unmount
      nil
    end # update_master_filename

    # Delete the filename from the master distribution point, if it exists.
    #
    # If you'll be uploading several files you can specify unmount as false, and do it manually when all
    # are finished.
    #
    # @param rw_pw[String] the password for the read/write account on the master Distribution Point
    #   or :prompt, or :stdin# where # is the line of stdin containing the password. See {Jamf::DistributionPoint#mount}
    #
    # @param unmount[Boolean] whether or not ot unount the distribution point when finished.
    #
    # @param dist_point [String,Integer] the name or id of the distribution
    #   point to use. Defaults to the Master Dist. Point
    #
    # @return [Boolean] was the file deleted?
    #
    def delete_master_file(rw_pw, unmount = true, dist_point: nil)
      dp = self.class.fetch_dist_point(dist_point, cnx: @cnx)
      file = dp.mount(rw_pw, :rw) + "#{DIST_POINT_PKGS_FOLDER}/#{@filename}"
      if file.exist?
        file.delete
        did_it = true
      else
        did_it = false
      end # if exists
      dp.unmount if unmount
      did_it
    end # delete master file

    # Delete this package from the JSS, optionally
    # deleting the master dist point file also.
    #
    # @param delete_file[Boolean] should the master dist point file be deleted?
    #
    # @param rw_pw[String] the password for the read/write account on the master Distribution Point
    #   or :prompt, or :stdin# where # is the line of stdin containing the password. See {Jamf::DistributionPoint#mount}
    #
    # @param unmount[Boolean] whether or not ot unount the distribution point when finished.
    #
    # @param dist_point [String,Integer] the name or id of the distribution
    #   point to use. Defaults to the Master Dist. Point
    #
    # @return [void]
    def delete(delete_file: false, rw_pw: nil, unmount: true, dist_point: nil)
      super()
      delete_master_file(rw_pw, unmount, dist_point: dist_point) if delete_file
    end

    # Install this package via the jamf binary 'install' command from the
    # distribution point for this machine.
    # See {Jamf::DistributionPoint.my_distribution_point}
    #
    # @note This code must be run as root to install packages
    #
    # The read-only or http passwd for the dist. point must be provided,
    # except for non-authenticated http downloads)
    #
    # @param args[Hash] the arguments for installation
    #
    # @option args :ro_pw[String] the read-only or http password for the
    #   distribution point for the local machine
    #   (http will be used if available, and may not need a pw)
    #
    # @option args :target[String,Pathname] The drive on which to install
    #  the package, defaults to '/'
    #
    # @option args :verbose [Boolean] be verbose to stdout, defaults to false
    #
    # @option args :feu[Boolean] fill existing users, defaults to false
    #
    # @option args :fut[Boolean] fill user template, defaults to false
    #
    # @option args :unmount[Boolean] unmount the distribution point when
    #   finished?(if we mounted it), defaults to false
    #
    # @option args :no_http[Boolean] don't use http downloads even if they
    #   are enabled for the dist. point.
    #
    # @option args :alt_download_url [String] Use this url for an http
    #   download, regardless of distribution point settings. This can be used
    #   to access Cloud Distribution Points if the fileshare isn't available.
    #   The URL should already be ur
    #   The package filename will be removed or appended as needed.
    #
    # @return [Boolean] did the jamf install succeed?
    #
    # @todo deal with cert-based https authentication in dist points
    #
    def install(**args)
      raise Jamf::UnsupportedError, 'You must have root privileges to install packages' unless JSS.superuser?

      args[:target] ||= '/'

      ro_pw = args[:ro_pw]

      # as of Casper 9.72, with http downloads, the jamf binary requires
      # the filename must be at the  end of the -path url, but before 9.72
      # it can't be.
      # e.g.
      #    in  <9.72:  jamf install  -package foo.pkg -path http://mycasper.myorg.edu/CasperShare/Packages
      # but
      #    in >=9.72:  jamf install  -package foo.pkg -path http://mycasper.myorg.edu/CasperShare/Packages/foo.pkg
      #
      append_at_vers = JSS.parse_jss_version('9.72')[:version]
      our_vers = JSS.parse_jss_version(@cnx.server.raw_version)[:version]
      no_filename_in_url = (our_vers < append_at_vers)

      # use a provided alternative url for an http download
      if args[:alt_download_url]

        # we'll re-add the filename below if needed.
        src_path = args[:alt_download_url].chomp "/#{@filename}"
        using_http = true
      # use our appropriate dist. point for download
      else
        mdp = Jamf::DistributionPoint.my_distribution_point cnx: @cnx

        # how do we access our dist. point? with http?
        if mdp.http_downloads_enabled && !(args[:no_http])
          using_http = true
          src_path = mdp.http_url
          if mdp.username_password_required
            raise Jamf::MissingDataError, 'No password provided for http download' unless ro_pw
            raise Jamf::InvaldDatatError, 'Incorrect password for http access to distribution point.' unless mdp.check_pw(:http, ro_pw)

            # insert the name and pw into the uri
            # reserved_chars = Regexp.new("[^#{URI::REGEXP::PATTERN::UNRESERVED}]") # we'll escape all the chars that aren't unreserved
            src_path = src_path.sub(%r{(https?://)(\S)},
                                    "#{Regexp.last_match(1)}#{CGI.escape mdp.http_username.to_s}:#{CGI.escape ro_pw.to_s}@#{Regexp.last_match(2)}")
          end

        # or with filesharing?
        else
          using_http = false
          src_path = mdp.mount(ro_pw)
        end

        # look at the pkgs folder
        src_path += "#{DIST_POINT_PKGS_FOLDER}/"
      end # if args[:alt_download_url]

      src_path += @filename.to_s if using_http && !no_filename_in_url

      # are we doing "fill existing users" or "fill user template"?
      do_feu = args[:feu] ? '-feu' : ''
      do_fut = args[:fut] ? '-fut' : ''

      # the install args for jamf
      command_args = "-package '#{@filename}' -path '#{src_path}'  -target '#{args[:target]}' #{do_feu} #{do_fut} -showProgress -verbose"

      # run it via a client cmd
      install_out = Jamf::Client.run_jamf :install, command_args, args[:verbose]

      install_out =~ %r{<exitCode>(\d+)</exitCode>}
      install_exit = Regexp.last_match(1) ? Regexp.last_match(1).to_i : nil
      install_exit ||= $CHILD_STATUS.exitstatus

      mdp.unmount if args.include?(:unmount) && !using_http

      install_exit.zero? ? true : false
    end

    # Uninstall this pkg via the jamf command.
    #
    # @param args[Hash] the arguments for installation
    #
    # @option args :target[String,Pathname] The drive from which to uninstall the package, defaults to '/'
    #
    # @option args :verbose[Boolean] be verbose to stdout, defaults to false
    #
    # @option args :feu[Boolean] fill existing users, defaults to false
    #
    # @option args :fut[Boolean] fill user template, defaults to false
    #
    # @return [Process::Status] the result of the 'jamf uninstall' command
    #
    # @note This code must be run as root to uninstall packages
    #
    def uninstall(**args)
      unless removable?
        raise Jamf::UnsupportedError, \
              'This package cannot be uninstalled. Please use CasperAdmin to index it and allow uninstalls'
      end
      raise Jamf::UnsupportedError, 'You must have root privileges to uninstall packages' unless JSS.superuser?

      args[:target] ||= '/'

      # are we doing "fill existing users" or "fill user template"?
      do_feu = args[:feu] ? '-feu' : ''
      do_fut = args[:fut] ? '-fut' : ''

      # use jamf binary to uninstall the pkg
      jamf_opts = "-target '#{args[:target]}' -id '#{@id}' #{do_feu} #{do_fut}"

      # run it via a client
      Jamf::Client.run_jamf 'uninstall', jamf_opts, args[:verbose]

      $CHILD_STATUS
    end

    # What type of package is this?
    #
    # @return [Symbol] :pkg or :dmg or:unknown
    #
    def type
      case @filename
      when /\.m?pkg(\.zip)?$/ then :pkg
      when /\.dmg$/ then :dmg
      else :unknown
      end
    end

    # Aliases
    ################################

    # aliases under their methods seem to confuse the YARD documenter, so I'm putting them all here.
    alias feu fill_existing_users
    alias feu? fill_existing_users
    alias fut fill_user_template
    alias fut? fill_user_template
    alias reboot reboot_required
    alias reboot? reboot_required
    alias oses os_requirements
    alias cpu_type required_processor
    alias removable allow_uninstalled
    alias removable? allow_uninstalled
    alias if_in_swupdate install_if_reported_available
    alias if_in_swupdate? install_if_reported_available
    alias boot boot_volume_required
    alias boot? boot_volume_required
    alias notify send_notification

    alias removable= allow_uninstalled=
    alias boot= boot_volume_required=
    alias feu= fill_existing_users=
    alias fut= fill_user_template=
    alias if_in_swupdate= install_if_reported_available=
    alias oses= os_requirements=
    alias reboot= reboot_required=
    alias cpu_type= required_processor=
    alias notify= send_notification=

    # Private Instance Methods
    ################################

    private

    # Return the REST XML for this pkg, with the current values,
    # for saving or updating
    #
    def rest_xml
      doc = REXML::Document.new Jamf::Connection::XML_HEADER
      pkg = doc.add_element 'package'
      pkg.add_element('allow_uninstalled').text = @allow_uninstalled
      pkg.add_element('boot_volume_required').text = @boot_volume_required
      pkg.add_element('filename').text = @filename
      pkg.add_element('fill_existing_users').text = @fill_existing_users
      pkg.add_element('fill_user_template').text = @fill_user_template
      pkg.add_element('info').text = @info
      pkg.add_element('install_if_reported_available').text = @install_if_reported_available
      pkg.add_element('name').text = @name
      pkg.add_element('notes').text = @notes
      pkg.add_element('os_requirements').text = JSS.to_s_and_a(@os_requirements)[:stringform]
      pkg.add_element('priority').text = @priority
      pkg.add_element('reboot_required').text = @reboot_required
      pkg.add_element('required_processor').text = @required_processor.to_s.empty? ? 'None' : @required_processor
      pkg.add_element('send_notification').text = @send_notification
      pkg.add_element('switch_with_package').text = @switch_with_package

      pkg.add_element('hash_type').text = @checksum_type
      pkg.add_element('hash_value').text = @checksum.to_s

      add_category_to_xml(doc)
      doc.to_s
    end # rest xml

  end # class Package

end # module Jamf
