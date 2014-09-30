proj_name = 'jss'
require "./lib/#{proj_name}/version"

Gem::Specification.new do |s|

  # General
  
  s.name        = proj_name
  s.version     = JSS::VERSION
  s.license     = 'Apache-2.0'
  s.date        = Time.now.utc.strftime("%Y-%m-%d")
  s.summary     = "A Ruby interface to the Casper Suite's JSS API"
  s.description = <<-EOD
    The JSS Gem is a framework for interacting with the REST API of the
    JAMF Software Server (JSS), the core of the Casper Suite from JAMF Software, Inc.
    JSS API objects are implemented as Ruby classes, and interact with each oher to
    allow simpler automation of Casper-related tasks. For details see README.md."
  EOD
  s.authors     = ["Chris Lasell"]
  s.email       = 'chrisl@pixar.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'http://oss.pixar.com/jssgem/'

  # Dependencies
  
  s.add_runtime_dependency 'plist', '~> 3.1.0'
  s.add_runtime_dependency 'ruby-mysql', '~> 2.9.12'
  s.add_runtime_dependency 'mime-types', '~> 1.25.1'
  s.add_runtime_dependency 'rest-client', '~> 1.6.8'
  s.add_runtime_dependency 'json' , '~> 1.6.5' 
  s.add_runtime_dependency 'net-ldap', '~> 0.3.1'


  # Rdoc
  
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE.md', 'CHANGES.md', 'THANKS.md']
  s.rdoc_options << '--title' << 'JSS' << '--line-numbers' << '--main' << 'README.md'
end
