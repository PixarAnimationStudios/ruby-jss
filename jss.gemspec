Gem::Specification.new do |s|
  s.name        = 'jss'
  s.version     = '0.0.1'
  s.date        = '2012-12-31'
  s.summary     = "a Ruby interface to the Casper Suite's JSS database"
  s.description = "Provides classes and methods for interacting with the JSS database, which sits behind JAMF Software's Casper Suite. Access is via the built-in REST API where possible and appropriate (and always when writing changes) but some queries are directly via MySQL for speed."
  s.author      = "Chris Lasell"
  s.email       = 'chrisl@pixar.com'
  s.files       = Dir['lib/**/*.rb']
  s.add_dependency('ruby-mysql', '~> 2.9.11')
  s.add_dependency('rest-client', '~> 1.6')
  s.add_dependency('json', '~> 1.6')
  
end