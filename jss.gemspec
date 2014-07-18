proj_name = 'jss'
require "./lib/#{proj_name}/version"

Gem::Specification.new do |s|
  s.name        = proj_name
  s.version     = JSS::VERSION
  s.date        = Time.now.utc.strftime("%Y-%m-%d")
  s.summary     = "A Ruby interface to the Casper Suite's JSS API"
  s.description = "Provides limited mapping of API objects to ruby objects"
  s.authors     = ["Chris Lasell"]
  s.email       = 'chrisl@pixar.com'
  s.files       = Dir['lib/**/*.rb']
  

  
  if RUBY_VERSION.start_with? "1.8"
    #s.add_dependency('mime-types', '=1.17.2')
    s.add_dependency('json', '=1.6.5')
    s.add_dependency('rest-client', '=1.6.7')
  else
    s.add_dependency('rest-client')
  end
  s.add_dependency('ruby-mysql', '~> 2.9')
  s.add_dependency('plist', '=3.1.0')
  
  s.has_rdoc = true
  s.rdoc_options << '--title' << 'JSS' << '--line-numbers'
end