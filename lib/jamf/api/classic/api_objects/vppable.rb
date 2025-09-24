# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

###
module Jamf

  # A mix-in module to handleVPP-related data in API objects that can be
  # assigned via VPP.
  #
  # NOTE: For now we are only working with device-based VPP assignments,
  # which are done via the scope of the VPPable object (macapp, mobdevapp, ebook)
  #
  # User-based APP assignments will require the creation of a VPPAssignment class,
  # and a VPPAssignmentScope class, since those scopes are very limited compared
  # to ordinary scope.
  #
  # To use this module, merely `include VPPable` when defining your
  # subclass of Jamf::APIObject
  #
  # classes doing so MUST call {#add_vpp_xml(xmldoc)} in their {#rest_xml} method
  #
  module VPPable

    # Mixed-in Constants
    #####################################
    VPPABLE = true

    # Mixed-in Class Methods
    #
    # This is a common technique to get class methods mixed in when
    # you 'include' a module full of instance methods
    #####################################

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    # Methods in here will become class methods of the
    # classes that include VPPable
    module ClassMethods

      # The names and assignment data for all class members that have
      # VPP licenses that can be assigned by device.
      # The assignment data is a hash of three keys pointing to integers:
      #   {
      #     total: int,
      #     used: int,
      #     remaining: int
      #   }
      #
      # WARNING: This must instantiate all objects, so is slow
      #
      # @return [Hash{String=>Hash}] The names and assignment data
      def all_vpp_device_assignable
        data = {}
        all_ids.each do |id|
          obj = fetch id: id
          next unless obj.vpp_device_based?

          data[obj.name] = {
            total: obj.vpp_licenses_total,
            used: obj.vpp_licenses_used,
            remaining: obj.vpp_licenses_remaining
          }
        end
        data
      end # all_vpp_device_assignable

    end # module ClassMethods

    # Mixed-in Attributes
    #####################################

    # @return [Hash]
    attr_reader :vpp_codes

    # @return [Integer]
    attr_reader :vpp_admin_account_id
    alias vpp_account_id vpp_admin_account_id

    # @return [Boolean]
    attr_reader :assign_vpp_device_based_licenses
    alias vpp_device_based? assign_vpp_device_based_licenses

    # @return [Integer]
    attr_reader :total_vpp_licenses
    alias vpp_licenses_total total_vpp_licenses

    # @return [Integer]
    attr_reader :remaining_vpp_licenses
    alias vpp_licenses_remaining remaining_vpp_licenses

    # @return [Integer]
    attr_reader :used_vpp_licenses
    alias vpp_licenses_used used_vpp_licenses

    #### How to assign VPP content & view assignments
    #
    # When doing device-based assignments, they are made via the
    # Scope of the VPPable Object.
    #
    # There is no indication in the device's API data that an app/book was
    # installed/licensed via VPP, it just shows up in the
    # list of installed apps like any other.
    #
    # When doing user-based assignments, they are made via the (limited)
    # scope of a 'Volume Assignment' object in Users -> Volume Assignement
    # These objects are sort of like policies or config profiles in that they have
    # payloads, and can assign multiple things at once (iosapps, macapps, ebooks)
    # These are available as vppassignment objects in the API.
    #
    # User-based assignments show up in the User's Jamf record
    # Users -> username -> (vpp acct name)
    # There you'll see the names of objects assigned to the user, and the
    # devices on which they've accepted the VPP invitation. In the User's
    # API data, there isaa 'vpp_assignments' arry of hash's like this:
    #    [{:id=>13733, :uid=>"258_13733"}]
    # However, that 'id' is not the id of any known vppassignment object, and
    # the uid is... ??  The object model at Developer.jamf.com says those
    # values should be an id and a name, probably pointing to a vppassignment
    # object, but that isn't the case.
    #
    #
    #### Figuring out how many, and where VPP lic. are used....
    #
    # IF dev. based assignement is turned on, then
    # the VPPable object (app, ebook) in the API will show the total numbers
    # of both user and device based assignments:
    #
    #  "vpp": {
    #   "assign_vpp_device_based_licenses": true,
    #   "vpp_admin_account_id": 1,
    #   "total_vpp_licenses": 2,
    #   "remaining_vpp_licenses": 0,
    #   "used_vpp_licenses": 2
    # }
    #
    # However, if assign_vpp_device_based_licenses is false, meaning
    # all assignments are user-based, then no other info is shown in the API.
    #
    # In that case, in the UI, you can see the total assignments in a table
    # in Settings -> Global Mgmt -> Volume Purch -> Content -> (ios/mac)
    # The numbers shown there indicate all assignments, whether user- or
    # deviced-based, just like the numbers in the API data for the VPPable
    # object, if they are there.
    # But there's no equivalent for that table data directly in the API when
    # device-based is false.
    #
    # Also in the UI you can see the intividual computers, mobiledevs, and users
    # to whom an object is assigned, no matter how it was assigned. Go to
    # Users -> Volume Assignments -> [any assigment object] -> Apps/Books -> ios/mac
    # and click on the number in the rightmost 'in use' column, and you'll
    # see a page with 3 tabs, showing the individual computers, mobdevs, or users
    # with the app/ebook assigned. EXCEPT this doesn't seem to expand
    # scoped groups - when I added a static computer group with one computer to
    # the scope of a MacApp, the total in-use count went up from 6 to 7, but the
    # list of computers two which it was assigned still showed only 6. :-(
    #
    # You can also get to the same page via: Users->SeachVolumeContent
    # then perform a simple search, and in the results page, click on the in-use
    # number. If you click on the VolumeAssignments number you'll see a
    # breakdown of the device assignments (from the app itself) and user assignments
    # and their scopes, but the scopes will not expand any groups, just list them.
    #
    # So 2 questions:
    # 1) How to see the total/used/remaining licenses for a VPPable object in the
    #   API, regardless of how it's deployed
    #
    # - first look at the VPPable object, and if the data is there, yer done.
    # - If not, then the object is only assigned to users, so we can loop thru
    #   the vppassignment objects and count things up.
    #
    # 2) How to learn where the VPPable object is actually assigned - i.e.
    #   a list of users and/or devices. Note: this isn't a list of where it's
    #   installed, but to whom/where it is assigned.
    #
    # - TLDR: no scopable object in Jamf gives you such a list, so we probably
    #   don't need it.
    #
    # In the UI, the page you get when clicking the 'in use' column of various
    # 'volume content' lists (see above) gets you the individually assigned
    # hardware or users, but doesn't show those via groups.
    # In the API - there doesn't seem to be any access at all, other than the
    # scopes of the VPPable Object itself, and any vppassignments that contain it.
    # Scanning through them is probably the only option, but could be slow once
    # there are many - and expanding those scopes into an actual list of users
    # and devices would be a pain to write
    #

    # Mixed-in Instance Methods
    #####################################

    # Set whether or not the VPP licenses should be assigned
    # by device as well as (or.. instead of?) by user
    #
    # @param new_val[Boolean] The new value
    #
    # @return [void]
    #
    def assign_vpp_device_based_licenses=(new_val)
      return if new_val == @assign_vpp_device_based_licenses

      @assign_vpp_device_based_licenses = Jamf::Validate.boolean new_val
      @need_to_update = true
    end
    alias vpp_device_based= assign_vpp_device_based_licenses=

    # @return [String] The name of the vpp admin acct for this object
    #
    def vpp_admin_account_name
      return unless @vpp_admin_account_id.is_a? Integer

      Jamf::VPPAccount.map_all_ids_to(:name)[@vpp_admin_account_id]
    end
    alias vpp_account_name vpp_admin_account_name

    # Mixed-in Private Instance Methods
    #####################################
    private

    # Parse the vpp data from the incoming API data
    #
    # @return [void]
    #
    def parse_vpp
      @vpp_codes = @init_data[:vpp_codes]
      vpp_data = @init_data[:vpp]
      @vpp_admin_account_id = vpp_data[:vpp_admin_account_id]
      @assign_vpp_device_based_licenses = vpp_data[:assign_vpp_device_based_licenses]
      @total_vpp_licenses = vpp_data[:total_vpp_licenses]
      @remaining_vpp_licenses = vpp_data[:remaining_vpp_licenses]
      @used_vpp_licenses = vpp_data[:used_vpp_licenses]
    end

    # Insert an appropriate vpp element into the XML for sending changes
    # to the JSS
    #
    # @param xdoc[REXML::Document] The XML document to work with
    #
    # @return [void]
    #
    def add_vpp_xml(xdoc)
      doc_root = xdoc.root
      vpp = doc_root.add_element 'vpp'
      vpp.add_element('assign_vpp_device_based_licenses').text = @assign_vpp_device_based_licenses.to_s
      vpp.add_element('vpp_admin_account_id').text = @vpp_admin_account_id.to_s
    end

  end # VPPable

end # JSS
