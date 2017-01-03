### Copyright 2017 Pixar

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


Gem::Specification.new do |s|

  s.name        = 'jss-api'
  s.version     = '0.6.2'
  s.license     = 'Modified Apache-2.0'
  s.date        = Time.now.utc.strftime("%Y-%m-%d")
  s.summary     = "A backward-compatibility wrapper for the ruby-jss gem (formerly jss-api)"
  s.description = <<-EOD
    This is the last version of the gem named jss-api. It exists merely as a pointer to the new
    gem 'ruby-jss' which provdes the same module going forward.
    Requiring 'jss-api' will merely require 'jss'. However, please update your code to require 'jss'
    directly, as this wrapper will eventually go away.
  EOD
  s.authors     = ["Chris Lasell"]
  s.email       = 'ruby-jss@pixar.com'
  s.homepage    = 'http://pixaranimationstudios.github.io/ruby-jss/'

  s.files       = Dir['lib/jss-api.rb']

  s.add_runtime_dependency 'ruby-jss', '>= 0.6.2'
end
