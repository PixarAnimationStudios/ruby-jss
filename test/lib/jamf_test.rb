# Copyright 2025 Pixar
#
#    Licensed under the terms set forth in the LICENSE.txt file available at
#    at the root of this project.
###
###

# Methods and constants for the tests
module JamfTest

  TOP_PREFIX = '>>>>>'.freeze
  TEST_PREFIX = '-->'.freeze

  ERROR_PREFIX1 = '****-> ERROR in :'.freeze
  ERROR_PREFIX2 = '****->   '.freeze

  def self.say(msg, from: :top)
    msgs = msg.is_a?(Array) ? msg : [msg]
    prefix =
      if from == :top
        TOP_PREFIX
      else
        "- #{from} #{TEST_PREFIX}"
      end
    msgs.each { |m| puts "#{prefix} #{m}" }
  end

  def self.report(a_problem)
    if a_problem.is_a? Exception
      puts caller_locations
      src = caller_locations(5..5).first
      msg = a_problem.to_s
    else
      src = caller_locations(3..3).first
      msg = a_problem
    end
    location = "method '#{src.label}' at line #{src.lineno} of #{File.basename src.path}"
    @errors << "#{location}: #{msg}"
    puts " #{ERROR_PREFIX1} #{location}"
    puts " #{ERROR_PREFIX2} #{msg}"
  end

end # module JamfTest

# load in the rest of the module
libdir = Pathname.new File.dirname(__FILE__)
moduledir = libdir + 'jamf_test'

# order matters, of course
require "#{moduledir}/auth"
require "#{moduledir}/APITest"
require "#{moduledir}/collection_tests"
require "#{moduledir}/prestage_tests"
require "#{moduledir}/advanced_search"
