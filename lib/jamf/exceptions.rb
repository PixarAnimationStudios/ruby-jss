# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
#
#

module Jamf

  # Exceptions
  #####################################

  # MissingDataError - raise this error when we
  # are missing args, or other simliar stuff.
  #
  class MissingDataError < RuntimeError; end

  # InvalidDataError - raise this error when
  # a data item isn't what we expected.
  #
  class InvalidDataError < RuntimeError; end

  # InvalidConnectionError - raise this error when we
  # don't have a usable connection to a network service, or
  # don't have proper authentication/authorization.
  #
  class InvalidConnectionError < RuntimeError; end

  # NoSuchItemError - raise this error when
  # a desired item doesn't exist.
  #
  class NoSuchItemError < RuntimeError; end

  # AlreadyExistsError - raise this error when
  # trying to create something that already exists.
  #
  class AlreadyExistsError < RuntimeError; end

  # AmbiguousError - raise this error when a search
  # term that should find one object finds more.
  #
  class AmbiguousError < RuntimeError; end

  # FileServiceError - raise this error when
  # there's a problem accessing file service on a
  # distribution point.
  #
  class FileServiceError < RuntimeError; end

  # UnmanagedError - raise this when we
  # try to do something managerial to
  # an unmanaged object
  #
  class UnmanagedError < RuntimeError; end

  # UnsupportedError - raise this when we
  # try to do something not yet supported
  #
  class UnsupportedError < RuntimeError; end

  # TimeoutError - raise this when we
  # try to do and it times out
  #
  class TimeoutError < RuntimeError; end

  # AuthenticationError - raise this when
  # a name/pw are wrong
  #
  class AuthenticationError < RuntimeError; end

  # Authorization error - rause this when the
  # user doesn't have permission to do something
  #
  class AuthorizationError < RuntimeError; end

  # ConflictError - raise this when
  # attempts to PUT or PUSH to the API
  # result in a 409 Conflict http error.
  # See {Jamf::Connection#raise_conflict_error}
  #
  class ConflictError < RuntimeError; end

  # BadRequestError - raise this when
  # attempts to PUT or PUSH or DELETE to the API
  # result in a 400 Bad Request http error.
  # See {Jamf::Connection.raise_bad_request_error}
  #
  class BadRequestError < RuntimeError; end

  # APIRequestError - raise this when
  # attempts API actions generate an error not dealt with
  # by ConflictError or BadRequestError
  # result in a 400 Bad Request http error.
  # See {Jamf::Connection.raise_api_error}
  #
  class APIRequestError < RuntimeError; end

end # module Jamf
