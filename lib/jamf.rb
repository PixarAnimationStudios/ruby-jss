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

# Required Libraries, etc
#####################################

# Standard Libraries
#
# TODO: Move some of these to where they are first needed so they aren't
# loaded unnecessarily
require 'English'
require 'json'
require 'yaml'
require 'pathname'
require 'fileutils'
require 'time'
require 'date'
require 'singleton'
require 'open-uri'
require 'ipaddr'
require 'rexml/document'
require 'base64'
require 'shellwords'
require 'digest'
require 'open3'

# Gems
require 'immutable-struct'
require 'concurrent'

# Load things not loaded by zeitwerk
require 'jamf/ruby_extensions'
require 'jamf/exceptions'
require 'jamf/db_connection'

# Configure the Zeitwerk loader, See https://github.com/fxn/zeitwerk
require 'zeitwerk'
require 'zeitwerk_config'

# touch this file to make zeitwerk and mixins send text to stderr as things load
# or get mixed in
JAMF_VERBOSE_LOADING_FILE = Pathname.new('/tmp/ruby-jss-verbose-loading')

# touch this file to make zeitwek  eager-load everything when the gem is required.
JAMF_ZEITWERK_EAGER_LOAD_FILE = Pathname.new('/tmp/ruby-jss-zeitwerk-eager-load')

# the `Zeitwerk::Loader.for_gem` creates the loader object, and must
# happen in this file, so we pass it into a method defined in
# zeitwerk_config
setup_zeitwerk_loader Zeitwerk::Loader.for_gem

# Jamf, A Ruby module for interacting with the JAMF Pro Server via both of its REST APIs
module Jamf

  def self.validate_ruby_version
    return if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new(MINIMUM_RUBY_VERSION)

    raise "Can't use ruby-jss #{Jamf::VERSION}, ruby itself must be version #{MINIMUM_RUBY_VERSION} or greater, this is ruby #{RUBY_VERSION}."
  end

  # the single instance of our configuration object
  def self.config
    Jamf::Configuration.instance
  end

  # Only look at the filesystem once.
  def self.verbose_loading?
    return @verbose_loading unless @verbose_loading.nil?

    @verbose_loading = JAMF_VERBOSE_LOADING_FILE.file?
  end

  # rubocop: disable Style/StderrPuts
  def self.load_msg(msg)
    return unless verbose_loading?

    $stderr.puts msg
  end
  # rubocop: enable Style/StderrPuts

  # These need to come after the definition of verboase_loading?
  # since they will try to use it when they get loaded
  ###################

  # DEPRECATED, use Jamf.config
  CONFIG = Jamf::Configuration.instance

  include Jamf::Constants
  extend Jamf::Utility
  extend Jamf::Connection::DefaultConnection

end # module Jamf

# make sure we can run
Jamf.validate_ruby_version

# backward compatibility, JSS module is now a synonym for Jamf module
JSS = Jamf

# testing zeitwerk loading
eager_load_for_testing if JAMF_ZEITWERK_EAGER_LOAD_FILE.file?
