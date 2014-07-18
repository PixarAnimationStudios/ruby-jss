#!/usr/bin/ruby

require "test/unit"

require File.expand_path(File.dirname(__FILE__)+'/../lib/jss')

class TestJSS < Test::Unit::TestCase
  
  def setup

  end # setup
   
  def teardown
    
  end #teardown
  
  #
  # Test the methods of the JSS module that don't use the API
  #
  
  def test_to_s_and_a
    s = "foo, bar, baz"
    a = %w{foo bar baz}
    expected = {:stringform => s, :arrayform => a}
    s_result = JSS.to_s_and_a s
    a_result = JSS.to_s_and_a a
    assert_equal expected, s_result
    assert_equal expected, a_result
  end #test_jss
  
  def test_expand_min_os
    expected = [ 
      "10.6.7", 
      "10.6.8", 
      "10.6.9", 
      "10.6.10", 
      "10.6.11", 
      "10.6.12", 
      "10.6.13", 
      "10.6.14", 
      "10.6.15", 
      "10.7.x", 
      "10.8.x", 
      "10.9.x", 
      "10.10.x", 
      "10.11.x", 
      "10.12.x", 
      "10.13.x", 
      "10.14.x", 
      "10.15.x", 
      "10.16.x", 
      "10.17.x", 
      "10.18.x", 
      "10.19.x"
    ]
    result = JSS.expand_min_os ">=10.6.7"
    assert_equal expected, result
  end
  
  def test_string_to_jss_datetime
    epoch_nine = '999999999'
    epoch_thirteen = '1234567890123'
    epoch_invalid = '3456'
    
    assert epoch_nine.to_jss_datetime.is_a?(DateTime), "nine-digit epoch is not a DateTime"
    assert epoch_thirteen.to_jss_datetime.is_a?(DateTime), "nine-digit epoch is not a DateTime"
    assert_raise JSS::InvalidDataError, "Invalid epoch didn't raise exception" do
      epoch_invalid.to_jss_datetime
    end
  end
  
  def test_parse_datetime
    assert JSS.parse_datetime(nil).nil?, "nil should return nil"
    assert JSS.parse_datetime(0).nil?, "zero should return nil"
    assert JSS.parse_datetime('').nil?, "empty string should return nil"
    result = JSS.parse_datetime(1234567890123)
    assert result.is_a?(DateTime), "parsed result is not a DateTime"
  end
  
  def test_escape_xml
    s = "a&b\"c<d>e'f"
    expected = "a&amp;b&quot;c&lt;d&gt;e&apos;f"
    assert_equal JSS.escape_xml(s), expected
  end
  
  def test_array_to_rexml_array
    assert_raise JSS::InvalidDataError, "Invalid arg didn't raise exception" do
     JSS.array_to_rexml_array(:foo, :bar)
    end
    
    el = :foo
    ar = ["bar", :morefoo]
    result = JSS.array_to_rexml_array(el,ar)
    
    assert result.is_a?(Array), "result is not an Array"
    result.each_index do |i|
      assert result[i].is_a?(REXML::Element), "result member is not a REXML Element"
      assert_equal result[i].name, el.to_s, "element name doesn't match '#{el}'"
      assert_equal result[i].text, ar[i].to_s, "element text doesn't match '#{ar[i]}'"
    end
  end
  
  def test_hash_to_rexml_array
    assert_raise JSS::InvalidDataError, "Invalid arg didn't raise exception" do
     JSS.hash_to_rexml_array(:foo)
    end
    
    h = {"foo" => "bar", "baz" => "morefoo"}
    
    result = JSS.hash_to_rexml_array h
    
    assert result.is_a?(Array), "result is not an Array"
    result.each_index do |i|
      assert result[i].is_a?(REXML::Element), "result member is not a REXML Element"
      assert h.keys.include?(result[i].name), "element name isn't in hash keys"
      assert h.values.include?(result[i].text), "element text isn't in hash values"
    end
  end
  
  def test_item_list_to_rexml_list
    list_el = "computers"
    item_el = "computer"
    items = [{:id=>2,:name=>'kimchi'},{:id=>5,:name=>'mantis'}]
    
    [:id, :name].each do |c|
      result = JSS.item_list_to_rexml_list list_el, item_el, items, c
      assert result.is_a?(REXML::Element), "result is not a REXML::Element"
      assert_equal result.name, list_el, "list element name incorrect"
      assert_equal result.elements[1].name, item_el, "item element name incorrect"
      assert_equal result.elements.count, 2, "wrong number of item elements"
      assert_equal result.elements[1].elements[1].name, c.to_s, "content element name is wrong"
      items.each_index{|i| assert_equal result.elements[i+1].elements[1].text, items[i][c].to_s, "content text is wrong" }
    end
  end
  
  def test_parse_jss_version
    v =  "9.32"
    gv = Gem::Version.new "9.3.2"
    expected = {:major=>9, :minor=>3, :revision=>"2", :version=>gv}
    result = JSS.parse_jss_version v
    assert_equal result, expected
    
    v =  "9.32.1234"
    gv = Gem::Version.new "9.3.2.1234"
    expected = {:major=>9, :minor=>3, :revision=>"2.1234", :version=>gv}
    result = JSS.parse_jss_version v
    assert_equal result, expected
    
    v =  "9.3.2.1234" # this should be the same as the above
    result = JSS.parse_jss_version v
    assert_equal result, expected
  end
  
end # class TestJSS

testdir = File.expand_path(File.dirname(__FILE__)+'/jss')
puts "#{testdir}/api"
require "#{testdir}/api"
