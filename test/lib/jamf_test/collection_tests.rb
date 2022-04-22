### Copyright 2022 Pixar

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

module JamfTest

  module CollectionTests

    # classes including this MUST define COLLECTION_CLASS, e.g.
    #
    # COLLECTION_CLASS = Jamf::Department

    TEST_OBJECT_BASE_NAME = 'ruby-jss-test'.freeze

    ########
    def collection_class
      self.class::COLLECTION_CLASS
    end

    ########
    def api
      @api_source ||= collection_class::API_SOURCE
    end

    ########
    def classic?
      api == :classic
    end

    ########
    def jpapi?
      api == :jamf_pro
    end

    # In JPAPI, ids are Strings containing integers. In CAPI, they are Integers
    #########
    def id_class
      @id_class ||= classic? ? Integer : String
    end

    ######
    def identifiers
      @identifiers ||= jpapi? ? collection_class.identifiers : collection_class.lookup_keys.values.uniq
    end

    ######
    def test_object_name
      @test_object_name ||= "#{TEST_OBJECT_BASE_NAME}-#{Jamf.cnx.user}-#{Time.now.strftime('%Y%m%d%H%M%S')}"
    end

    ##############################################

    # The main test method
    #
    # @param do_object_tests [Boolean] do CRUD tests on test-objects in this collection
    #
    def run_collection_tests(do_object_tests: true)
      # Order Matters! Instance variabls are set and used throughout
      all
      if @cached_all.empty?
        say 'The result of .all was empty, skipping related collection tests'
        return
      end

      sorted_all
      filtered_all
      all_identifiers
      cached_list_all_ids
      map_all
      cached_list_map_all
      valid_id
      fetch_random
      return unless do_object_tests

      # The methods below are very basic and assume a simple object
      # that can be created with only a 'name'.
      #
      # For anything more complex, they should be overridden in the classes that
      # mixin this module, since the details will be very different
      # See inventory_preload_record.rb for an example

      create_new
      add_data_to_new
      save_new
      fetch_new
      validate_fetched
      modify_fetched
      re_save_fetched
      re_fetch
      validate_changes
      delete
      confirm_deleted
    ensure
      ensure_deleted
    end

    ########### Collection Class Tests
    ####################################

    # No need to test pagers, because .all uses a pager
    #################
    def all
      @cached_all = collection_class.all
      say "Ran #{collection_class}.all"

      validate_array @cached_all, item_class: Hash
      return if @cached_all.empty?

      one_of_all = @cached_all.sample

      validate_hash one_of_all, has_key: :id, class_for_has_key: id_class
    end

    #################
    def sorted_all
      return unless jpapi?

      if @cached_all.empty?
        say "There are no #{collection_class} objects on the server, not testing sorted_all"
        return
      end
      sorted_desc = collection_class.all sort: 'id:desc'
      raise "#{collection_class}.all sort: 'id:desc' ; didn't work as expected" unless sorted_desc.first[:id].to_i >= sorted_desc.last[:id].to_i

      say "Ran #{collection_class}.all sort: 'id:desc'"
    end

    #################
    def filtered_all
      return unless jpapi?
      return unless defined? collection_class::FILTER_KEYS
      return unless defined? collection_class::FILTER_KEYS

      if @cached_all.empty?
        say "There are no #{collection_class} objects on the server, not testing filtered_all"
        return
      end

      fkey = collection_class::FILTER_KEYS.sample
      fval = @cached_all.sample[fkey]
      filter = "#{fkey}==\"#{fval}\""
      filtered = collection_class.all filter: filter

      say "Ran #{collection_class}.all filter: '#{filter}'"
    end

    #################
    def all_identifiers
      if @cached_all.empty?
        say "There are no #{collection_class} objects on the server, not testing all_identifiers"
        return
      end

      ids = collection_class.all_ids
      say "Ran #{collection_class}.all_ids"
      validate_array ids, item_class: id_class


      identifiers.each do |ident|
        next if ident == :id

        mth = ident.to_s.end_with?('s') ? "all_#{ident}es" : "all_#{ident}s"
        collection_class.send mth
        say "Ran #{collection_class}.#{mth}"
      end
    end

    ################
    def cached_list_all_ids
      if @cached_all.empty?
        say "There are no #{collection_class} objects on the server, not testing cached_list:"
        return
      end

      cached_ids = collection_class.all_ids cached_list: @cached_all
      say "Ran #{collection_class}.all_ids cached_list: @cached_all"
      validate_array cached_ids, item_class: id_class

    end

    #################
    def map_all
      if @cached_all.empty?
        say "There are no #{collection_class} objects on the server, not testing map_all"
        return
      end

      if classic?
        ids_to_names = Jamf::Policy.map_all_ids_to :name, :refresh
        say 'Ran legacy Jamf::Policy.map_all_ids_to :name, :refresh'

        validate_hash ids_to_names
        validate_array ids_to_names.keys, item_class: Integer
        validate_array ids_to_names.values, item_class: String

      end

      other_key = (collection_class.all.sample.keys - [:id]).sample
      ids_to_other = collection_class.map_all :id, to: other_key

      say "Ran modern Jamf::Policy.map_all :id, to: :#{other_key}"

      validate_hash ids_to_other
      validate_array ids_to_other.keys, item_class: id_class

    end

    ################
    def cached_list_map_all
      if @cached_all.empty?
        say "There are no #{collection_class} objects on the server, not testing map_all cached_list:"
        return
      end

      if classic?
        ids_to_names = Jamf::Policy.map_all_ids_to :name, cached_list: @cached_all
        say 'Ran legacy Jamf::Policy.map_all_ids_to :name, cached_list: @cached_all'

        validate_hash ids_to_names
        validate_array ids_to_names.keys, item_class: Integer
        validate_array ids_to_names.values, item_class: String

      end

      other_key = (collection_class.all.sample.keys - [:id]).sample
      ids_to_other = collection_class.map_all :id, to: other_key, cached_list: @cached_all

      say "Ran modern Jamf::Policy.map_all :id, to: :#{other_key}, cached_list: @cached_all"

      validate_hash ids_to_other
      validate_array ids_to_other.keys, item_class: id_class

    end

    ################
    def valid_id
      if @cached_all.empty?
        say "There are no #{collection_class} objects on the server, not testing valid_id"
        return
      end

      other_ident = (identifiers - [:id]).sample
      ids_to_other_ident = collection_class.map_all :id, to: other_ident
      id, other = ids_to_other_ident.to_a.sample

      valid_id = collection_class.valid_id other
      raise "#{collection_class} id #{id}, has #{other_ident} '#{other}', but calling .valid_id('#{other}') returned id: #{valid_id}" unless id.to_s == valid_id.to_s

      say "#{collection_class}.valid_id for #{other_ident} '#{other}' returned the correct id"
    end

    ################
    def fetch_random
      if @cached_all.empty?
        say "There are no #{collection_class} objects on the server, not testing fetch_random"
        return
      end

      rando = collection_class.fetch random: true
      say "Ran #{collection_class}.fetch random: true "
    end

    ########### Object Tests
    ####################################


    # override this if the class requires more than 'name' with .create
    ################
    def create_new
      @unsaved_new_object = collection_class.create name: test_object_name
      say "Created new #{collection_class}, to be saved in Jamf."

    end

    # override this if your class can take more than 'name'
    ################
    def add_data_to_new
      nil
    end

    ################
    def save_new
      @new_object_id = @unsaved_new_object.save
      say "Saved new #{collection_class} id: #{@new_object_id}"
    end

    # the `val_to_fetch` is used both for the searchterm and by_ident
    # e.g. if val to fetch is 'foobar'
    # searchterm fetch will be .fetch 'foobar'
    # and if ident is ':displayname' then ident fetch will be .fetch displayname: 'foobar'
    ################
    def fetch_new(by_name: true, by_searchterm: true, by_ident: nil, val_to_fetch: nil)
      @fetched_new_object = collection_class.fetch id: @new_object_id
      say "Fetched new instance of #{collection_class} id: #{@new_object_id} by id"

      if by_name
        collection_class.fetch name: test_object_name
        say "Fetched new instance of #{collection_class} id: #{@new_object_id} by explicit name"
      end

      if by_searchterm
        val_to_fetch ||= test_object_name
        collection_class.fetch val_to_fetch
        say "Fetched new instance of #{collection_class} id: #{@new_object_id} by searchterm '#{val_to_fetch}'"
      end
      return unless by_ident && val_to_fetch

      collection_class.fetch(**{ by_ident => val_to_fetch })
      say "Fetched new instance of #{collection_class} id: #{@new_object_id} by '#{by_ident}: #{val_to_fetch}'"
    end

    ################
    def validate_fetched
      raise 'Original ruby object created with .create is not == to the one re-fetched after saving!' unless @fetched_new_object == @unsaved_new_object

      say "Fetched instance of #{collection_class} is == to the original one we made with .create"
    end

    ################
    def modify_fetched
      @test_object_name_edited = "#{test_object_name}-edited"
      @fetched_new_object.name = @test_object_name_edited

      say "Changed local instance name from '#{test_object_name}' to '#{@test_object_name_edited}'"
    end

    ################
    def re_save_fetched
      @fetched_new_object.save
      say "Saved changes to #{collection_class}"
    end

    ################
    def re_fetch
      @fetched_edited_object = collection_class.fetch name: @test_object_name_edited
      say "Fetched fresh instance of #{collection_class} id: #{@new_object_id} by its new name"
    end

    ################
    def validate_changes
      # override this if you changed more than the name.
      # the re-fetch above validated the name change
      nil
    end

    ################
    def delete
      @fetched_edited_object.delete
      say "Deleted #{collection_class} id: #{@new_object_id} from Jamf Pro"
    end

    ################
    def confirm_deleted
      all_ids = classic? ? collection_class.all_ids(:refresh) : collection_class.all_ids

      raise "#{collection_class} id: #{@new_object_id} was NOT deleted from Jamf Pro" if all_ids.include? @new_object_id

      say "Confirmed deletion of #{collection_class} id: #{@new_object_id} from Jamf Pro"
    end

    ###############
    def ensure_deleted
      return unless @new_object_id

      collection_class.delete @new_object_id
    end

  end # module

end # module JamfTest
