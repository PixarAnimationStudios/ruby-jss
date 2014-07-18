#!/usr/bin/ruby

require "test/unit"
require File.expand_path(File.dirname(__FILE__)+'/../../lib/jss')

class TestAPIConnection < Test::Unit::TestCase
  
  # run the tests in the order defined, so we 
  # only have to connect once, and we know 
  # we create things before we update or delete them.
  # self.test_order = :defined 
  
  def setup
    # TEMPORARY
    @jss_server = "casper.pixar.com"
    @jss_user = "macadmin"
    @jss_pw = "IKamw/t7"
    
    unless @jss_server
      print "JSS server:"
      @jss_server = gets.chomp
    end
    unless @jss_user
      print "JSS Admin Username:"
      @jss_user = gets.chomp
    end
    unless @jss_pw
      print "#{@jss_user}'s password:"
      @jss_pw = gets.chomp
    end
    
    @api = JSS::API
    @test_category_name = "jss-rubygem-test-category"
    @test_category_new_name = "jss-rubygem-test-category-renamed"
    @test_category_rsrc = "categories/name/#{@test_category_name}"
    @test_category_xml = "<category><name>#{@test_category_name}</name></category>"
    @test_category_new_xml = "<category><name>#{@test_category_new_name}</name></category>"
    
  end # setup
   
  def teardown
  end #teardown
  
  def test_a_connect
    
    assert_raise JSS::MissingDataError do
       @api.connect :server => @jss_server
    end
    assert_raise JSS::MissingDataError do
       @api.connect :user => @jss_user , :pw => @jss_pw
    end
    assert_raise JSS::InvalidConnectionError do
       @api.get_rsrc 'accounts'
    end
    assert_nothing_raised do
      @api.connect  :user => @jss_user , :pw => @jss_pw, :server => @jss_server
    end
    
    assert @api.cnx.is_a?(RestClient::Resource)
    assert @api.server.is_a?(JSS::Server)

  end # test connect
  
  def test_b_get_rsrc
    result = @api.get_rsrc 'accounts'
    assert result.is_a? Hash
    accts = result[:accounts]
    assert accts.is_a? Hash
    assert accts[:groups].is_a? Array
    assert accts[:users].is_a? Array
    assert accts[:users][0].is_a? Hash
    assert accts[:users][0].keys.include? :name
    assert accts[:users][0].keys.include? :id
    assert accts[:users][0][:id].is_a? Integer
  end 

  def test_c_post_put_delete
  
    result = @api.post_rsrc :rsrc => @test_category_rsrc, :xml => @test_category_xml
    assert_match %r{<category><id>(\d+)</id></category>}, result, "failed to post"
    result =~ %r{<category><id>(\d+)</id></category>}
    @test_category_id = $1
    @test_category_rsrc = "categories/id/#{@test_category_id}"
    result = @api.get_rsrc(@test_category_rsrc)[:category]
    assert_equal result[:name], @test_category_name, "retrieved name differs from saved name"

    result = @api.put_rsrc :rsrc => @test_category_rsrc, :xml => @test_category_new_xml
    assert_match %r{<category><id>#{@test_category_id}</id></category>}, result, "failed to put"
    list = @api.get_rsrc('categories')[:categories]
    assert list.map{|l|l[:name]}.include?(@test_category_new_name), "new name not in list"

    result = @api.delete_rsrc @test_category_rsrc
    assert_match %r{<successful>true</successful>}, result, "failed to delete"
    list = @api.get_rsrc('categories')[:categories]
    assert (not list.map{|l| l[:name] }.include?(@test_category_new_name) ) , "new name still in list"
  end
  
  def test_f_disconnect
        
    @api.disconnect
    assert @api.cnx.nil?, "cnx not nil after disconnect"
    assert (not @api.connected), "connected not false after disconnect"
        
  end
end # class TestPackage