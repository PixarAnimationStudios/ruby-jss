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

    # The main test method
    def run_collection_tests
      # Order Matters! Instance variabls are set and used throughout
      all
      sorted_all
      filtered_all
      all_identifiers
      cached_list_all_ids
      map_all
      cached_list_map_all

      # Tests like those listed here should be custom written
      # in the test classes, cuz the details are too variable to
      # generalize in this mixin module.

      # create_new
      # add_data_to_new
      # save_new
      # fetch_new
      # validate_fetched
      # modify_fetched
      # re_save_fetched
      # re_fetch
      # validate_changes
      # delete
      # confirm_deleted
    end

    # No need to test pagers, because .all uses a pager
    #################
    def all
      @cached_all = collection_class.all
      say "Ran #{collection_class}.all"

      validate_array @cached_all, item_class: Hash
      one_of_all = @cached_all.sample

      validate_hash one_of_all, has_key: :id, val_class: id_class
      say '..output looks good'
    end

    #################
    def sorted_all
      return unless jpapi?

      sorted_desc = collection_class.all sort: 'id:desc'
      raise "#{collection_class}.all sort: 'id:desc' ; didn't work as expected" unless sorted_desc.first[:id] >= sorted_desc.last[:id]

      say "Ran #{collection_class}.all sort: 'id:desc'"
    end

    #################
    def filtered_all
      return unless jpapi?
      return unless defined? collection_class::FILTER_KEYS
      return unless defined? collection_class::FILTER_KEYS

      fkey = collection_class::FILTER_KEYS.sample
      fval = @cached_all.sample[fkey]
      filter = "#{fkey}==\"#{fval}\""
      filtered = collection_class.all filter: filter
      raise "#{collection_class}.all filter: '#{filter}' ; came back empty" if filtered.empty?

      say "Ran #{collection_class}.all filter: '#{filter}'"
    end

    #################
    def all_identifiers
      ids = collection_class.all_ids
      say "Ran #{collection_class}.all_ids"
      validate_array ids, item_class: id_class
      say '..output looks good'

      identifiers.each do |ident|
        next if ident == :id

        mth = ident.end_with?('s') ? "all_#{ident}es" : "all_#{ident}s"
        collection_class.send mth
        say "Ran #{collection_class}.#{mth}"
      end
    end

    ################
    def cached_list_all_ids
      cached_ids = collection_class.all_ids cached_list: @cached_all
      say "Ran #{collection_class}.all_ids cached_list: @cached_all"
      validate_array cached_ids, item_class: id_class
      say '..output looks good'
    end

    #################
    def map_all
      if classic?
        ids_to_names = Jamf::Policy.map_all_ids_to :name, :refresh
        say 'Ran legacy Jamf::Policy.map_all_ids_to :name, :refresh'

        validate_hash ids_to_names
        validate_array ids_to_names.keys, item_class: Integer
        validate_array ids_to_names.values, item_class: String
        say '..output looks good'
      end

      other_key = (collection_class.all.sample.keys - [:id]).sample
      ids_to_other = collection_class.map_all :id, to: other_key

      say "Ran modern Jamf::Policy.map_all :id, to: :#{other_key}"

      validate_hash ids_to_other
      validate_array ids_to_other.keys, item_class: id_class
      say '..output looks good'
    end

    ################
    def cached_list_map_all
      if classic?
        ids_to_names = Jamf::Policy.map_all_ids_to :name, cached_list: @cached_all
        say 'Ran legacy Jamf::Policy.map_all_ids_to :name, cached_list: @cached_all'

        validate_hash ids_to_names
        validate_array ids_to_names.keys, item_class: Integer
        validate_array ids_to_names.values, item_class: String
        say '..output looks good'
      end

      other_key = (collection_class.all.sample.keys - [:id]).sample
      ids_to_other = collection_class.map_all :id, to: other_key, cached_list: @cached_all

      say "Ran modern Jamf::Policy.map_all :id, to: :#{other_key}, cached_list: @cached_all"

      validate_hash ids_to_other
      validate_array ids_to_other.keys, item_class: id_class
      say '..output looks good'
    end

  end # module

end # module JamfTest
