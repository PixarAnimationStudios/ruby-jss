# Copyright 2022 Pixar
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

module Jamf

  # This mixin implements the .../delete-multiple endpoints that
  # some collection resources have (and eventually all will??)
  # It should be extended into classes representing those resources
  #
  module BulkDeletable

    DELETE_MULTIPLE_ENDPOINT = 'delete-multiple'.freeze

    # Delete multiple objects by providing an array of their
    #
    # @param ids [Array<String,Integer>] The ids to delete
    #
    # @param cnx [Jamf::Connection] The connection to use, default: Jamf.cnx
    #
    # TODO: fix this return value, no more ErrorInfo
    # @return [Array<Jamf::Connection::JamfProAPIError::ErrorInfo] Info about any ids
    #   that failed to be deleted.
    #
    def bulk_delete(ids, cnx: Jamf.cnx)
      ids = [ids] unless ids.is_a? Array
      request_body = { ids: ids.map(&:to_s) }

      begin
        cnx.post "#{rsrc_path}/#{DELETE_MULTIPLE_ENDPOINT}", request_body
        []
      rescue Jamf::Connection::JamfProAPIError => e
        raise e unless e.httpStatus == 400

        e.errors
      end
    end

  end # Lockable

end # Jamf
