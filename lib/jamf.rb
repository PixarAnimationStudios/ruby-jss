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
require 'jamf/zeitwerk_config'

# the `Zeitwerk::Loader.for_gem` creates the loader object, and must
# happen in this file, so we pass it into a method defined in
# zeitwerk_config
JamfZeitwerkConfig.setup_zeitwerk_loader Zeitwerk::Loader.for_gem

# Jamf, A Ruby module for interacting with the JAMF Pro Server via both of its REST APIs
module Jamf

  # Use the load_msg method defined for Zeitwerk
  def self.load_msg(msg)
    JamfZeitwerkConfig.load_msg msg
  end  

  # the single instance of our configuration object
  def self.config
    Jamf::Configuration.instance
  end

  # These need to come after the definition of verboase_loading?
  # since they will try to use it when they get loaded
  ###################

  include Jamf::Constants
  extend Jamf::Utility
  extend Jamf::Connection::DefaultConnection

end # module Jamf

# JSS module is now a synonym for Jamf module
JSS = Jamf

# testing zeitwerk loading, the the desired file is present
JamfZeitwerkConfig.eager_load_for_testing 
