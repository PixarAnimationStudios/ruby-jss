# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
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
