### Copyright 2022 Pixar

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
###

# Methods and constants for the tests
module JSSTestHelper

  TOP_PREFIX = '>>>>>'.freeze
  TEST_PREFIX = '---->'.freeze

  ERROR_PREFIX1 = '****-> ERROR in :'.freeze
  ERROR_PREFIX2 = '****->   '.freeze

  module_function

  def say(msg, from: :top)
    msgs = msg.is_a?(Array) ? msg : [msg]
    prefix =
      if from == :top
        TOP_PREFIX
      else
        puts # for interlacing with minitest's dots
        "-- #{from} #{TEST_PREFIX}"
      end
    msgs.each { |m| puts "#{prefix} #{m}" }
  end

  def report(a_problem)
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

end # module JSSTestHelper

# load in the rest of the module
libdir = Pathname.new File.dirname(__FILE__)
moduledir = libdir + 'testhelper'
moduledir.children.each { |mf| load mf.to_s }
