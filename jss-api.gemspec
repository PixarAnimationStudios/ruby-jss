### Copyright 2014 Pixar
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

proj_name = 'jss-api'

require "./lib/#{proj_name}/version"

Gem::Specification.new do |s|

  # General
  
  s.name        = proj_name
  s.version     = JSS::VERSION
  s.license     = 'Modified Apache-2.0'
  s.date        = Time.now.utc.strftime("%Y-%m-%d")
  s.summary     = "A Ruby interface to the Casper Suite's JSS API"
  s.description = <<-EOD
    The JSS Gem is a framework for interacting with the REST API of the
    JAMF Software Server (JSS), the core of the Casper Suite from JAMF Software, LLC.
    JSS API objects are implemented as Ruby classes, and interact with each oher to
    allow simpler automation of Casper-related tasks. For details see README.md."
  EOD
  s.authors     = ["Chris Lasell"]
  s.email       = 'chrisl@pixar.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'http://pixaranimationstudios.github.io/jss-api-gem/index.html'

  # Dependencies
  
  s.add_runtime_dependency 'plist' #, '~> 3.1.0'
  s.add_runtime_dependency 'ruby-mysql' #, '~> 2.9.12'
  s.add_runtime_dependency 'mime-types' #, '~> 1.25.1'
  s.add_runtime_dependency 'rest-client' #, '~> 1.6.8'
  s.add_runtime_dependency 'json'  #, '~> 1.6.5' 
  s.add_runtime_dependency 'net-ldap' #, '~> 0.3.1'


  # Rdoc
  
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt', 'CHANGES.md', 'THANKS.md']
  s.rdoc_options << '--title' << 'JSS' << '--line-numbers' << '--main' << 'README.md'
end
