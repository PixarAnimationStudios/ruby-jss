# Copyright 2020 Pixar

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
require 'recursive-open-struct'

# Configure the Zeitwerk loader, See https://github.com/fxn/zeitwerk
require 'zeitwerk'
require 'zeitwerk_config'
setup_zeitwerk_loader Zeitwerk::Loader.for_gem

# Jamf, A Ruby module for interacting with the JAMF Pro Server via both of its REST APIs
module Jamf

  include Jamf::Constants
  extend Jamf::Utility

  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new(MINIMUM_RUBY_VERSION)
    raise "Can't use the JSS module, ruby itself must be version #{MINIMUM_RUBY_VERSION} or greater."
  end

end # module Jamf

# backward compatibility, JSS module is the same as Jamf module
JSS = Jamf

# Load things not loaded by zeitwerk
require 'jamf/ruby_extensions'
require 'jamf/exceptions'

# for testing the Zeitwrk Loader... normally we want autoloading on demand,
# eager loading loads everything
begin
  z_loader.eager_load(force: true)
rescue Zeitwerk::NameError => e
  puts e.message
else
  puts :loaded
end
