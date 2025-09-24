# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###

proj_name = 'ruby-jss'
lib_dir = 'jamf'

require "./lib/#{lib_dir}/version"

Gem::Specification.new do |s|
  # General
  s.description = <<~EODESC
    The ruby-jss gem provides native ruby access to the REST APIs of Jamf Pro,
    an enterprise/education tool for managing Apple devices, from jamf.com.
    The Jamf module provides access to both the 'Classic' API and the more modern
    'Jamf Pro' API. Jamf Pro objects are implemented as classes and can interact
    with each other. Authentication tokens, data transfer using JSON or XML and other
    details are handled automatically under the hood to allow simpler, intuitive
    automation of Jamf-related tasks.
  EODESC

  s.name        = proj_name
  s.version     = Jamf::VERSION
  s.license     = 'LicenseRef-LICENSE.txt'
  s.date        = Time.now.utc.strftime('%Y-%m-%d')
  s.summary     = 'A Ruby interface to the Jamf Pro REST APIs'
  s.authors     = ['Chris Lasell', 'Aurica Hayes']
  s.email       = 'ruby-jss@pixar.com'
  s.homepage    = 'http://pixaranimationstudios.github.io/ruby-jss/'
  s.metadata    = {
    'source_code_uri' => 'https://github.com/PixarAnimationStudios/ruby-jss',
    'changelog_uri' => 'https://github.com/PixarAnimationStudios/ruby-jss/blob/master/CHANGES.md',
    'wiki_uri' => 'https://github.com/PixarAnimationStudios/ruby-jss/wiki'
  }

  s.files = Dir['lib/**/*.rb']
  s.files << '.yardopts'
  s.files += Dir['data/**/*']
  s.files += Dir['test/**/*']

  s.executables << 'cgrouper'
  s.executables << 'netseg-update'
  s.executables << 'jamfHelperBackgrounder'

  # Dependencies
  s.required_ruby_version = '>= 2.6.3'

  # https://github.com/ckruse/CFPropertyList  MIT License (no dependencies)
  s.add_runtime_dependency 'CFPropertyList', '~> 3.0'

  # https://github.com/tmtm/ruby-mysql Ruby License (no dependencies)
  # DEPRECATED: mysql support in ruby-jss will be removed eventually
  s.add_runtime_dependency 'ruby-mysql', '~> 2.9', '>= 2.9.12'

  # https://github.com/lostisland/faraday: MIT License
  s.add_runtime_dependency 'faraday', '~> 2.0'

  # https://github.com/lostisland/faraday-multipart & dependencies: MIT License
  s.add_runtime_dependency 'faraday-multipart', '~> 1.0', '>= 1.0.4'

  # https://github.com/ruby-concurrency/concurrent-ruby MIT License (no dependencies)
  s.add_runtime_dependency 'concurrent-ruby', '~> 1.1'

  # https://github.com/stitchfix/immutable-struct MIT License (no dependencies)
  # TODO: replace this with the one from concurrent-ruby
  s.add_runtime_dependency 'immutable-struct', '~> 2.3'

  # https://github.com/fxn/zeitwerk MIT License (no dependencies)
  s.add_runtime_dependency 'zeitwerk', '~> 2.5', '>= 2.5.4'

  # Ruby 3.0+ doesn't include rexml in the stdlib, but
  # the min. version of ruby 2 we support includes v 3.1.9
  s.add_runtime_dependency 'rexml', '~> 3.1', '>= 3.1.9'

  # Rdoc
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt', 'CHANGES.md', 'THANKS.md', 'README-2.0.0.md']
  s.rdoc_options << '--title' << 'Jamf' << '--line-numbers' << '--main' << 'README.md'
end
