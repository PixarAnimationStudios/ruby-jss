#!/usr/bin/ruby

u = "macadmin"
pw = "IKamw/t7"

#require '/Users/chrisl/Box Sync/gems/jss/lib/jss.rb'
require 'jss'

JSS::API.connect :user => u, :pw => pw, :server => 'casper.pixar.com'

here = File.dirname(__FILE__)
require "#{here}/simple_objects"
require "#{here}/computer"
