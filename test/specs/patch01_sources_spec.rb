### Copyright 2018 Pixar

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
# Patch Source MetaClass
#
describe JSS::PatchSource do

  ##### Specs

  it 'can list all patch sources' do
    JSS::PatchSource.all.must_be_instance_of Array
    JSS::PatchSource.all.first.must_be_instance_of Hash
  end

  it 'can be used to fetch subclass' do
    JSS::PatchSource.fetch(id: 1).must_be_instance_of JSS::PatchInternalSource
  end

  it 'can list available titles for a subclass from class method' do
    titles = JSS::PatchSource.available_titles 1
    titles.must_be_instance_of Array
    titles.first.must_be_instance_of Hash
    titles.first[:last_modified].must_be_instance_of Time
  end

  it 'can list available name_ids for a subclass from class method' do
    name_ids = JSS::PatchSource.available_name_ids 1
    name_ids.must_be_instance_of Array
    name_ids.first.must_be_instance_of String
  end

end # describe JSS::PatchSource

# Internal Sources
#
describe JSS::PatchInternalSource do

  ##### Class Methods

  ##### Instance Methods

  # shortcut
  def src
    JSSTestHelper::PatchMgmt.internal_src
  end

  ##### Specs

  it 'cannot be created' do
    proc { JSS::PatchInternalSource.make name: 'foo' }.must_raise JSS::UnsupportedError
  end

  it 'cannot be modified' do
    proc { src.host_name = 'foo' }.must_raise NoMethodError
    proc { src.port = 'foo' }.must_raise NoMethodError
  end

  it 'cannot be disabled' do
    proc { src.disable }.must_raise NoMethodError
  end

  it 'cannot be deleted' do
    proc { src.delete }.must_raise JSS::UnsupportedError
  end

  it 'tells us if it is enabled' do
    JSS::TRUE_FALSE.must_include src.enabled?
  end

  it 'tells us its hostname' do
    src.host_name.must_be_instance_of String
    src.host_name.wont_be_empty
  end

  it 'tells us its port' do
    src.port.must_be_kind_of Integer
  end

  it 'tells us if ssl is enabled' do
    JSS::TRUE_FALSE.must_include src.ssl_enabled?
  end

  it 'lists its available titles' do
    titles = src.available_titles
    titles.must_be_instance_of Array
    titles.first.must_be_instance_of Hash
    titles.first[:last_modified].must_be_instance_of Time
  end

  it 'lists its available name_ids' do
    name_ids = src.available_name_ids
    name_ids.must_be_instance_of Array
    name_ids.first.must_be_instance_of String
  end

end # describe JSS::PatchInternalSource

# External Sources
#
describe JSS::PatchExternalSource do

  ##### Constants

  ##### Class methods

  # this effectively makes the tests run in the order defined, which is
  # needed in this situattion.
  def self.test_order
    :alpha
  end

  ##### Instance Methods

  # shortcut
  def src
    JSSTestHelper::PatchMgmt.external_src
  end

  ##### Specs

  it 'can delete crufty objects from earlier tests' do
    crufty_name = JSSTestHelper::PatchMgmt::EXT_SRC_NAME
    break unless JSS::PatchExternalSource.all_names(:refresh).include? crufty_name

    puts 'Found crufty External Source from Previous Tests - deleting'

    crufty_id = JSS::PatchExternalSource.map_all_ids_to(:name).invert[crufty_name]
    deleted = JSS::PatchExternalSource.delete crufty_id

    deleted.must_be_instance_of Array
    deleted.must_be_empty
    JSS::PatchExternalSource.all_names(:refresh).wont_include crufty_name
  end

  it 'can be made' do
    src.must_be_instance_of JSS::PatchExternalSource
  end

  it 'cannot be created without a host' do
    proc { src.save }.must_raise JSS::UnsupportedError
  end

  it 'can be created with a host' do
    src.host_name = JSSTestHelper::PatchMgmt::EXT_SRC_NAME
    src.save.must_be_kind_of Integer
  end

  it 'can set the port' do
    src.port = JSSTestHelper::PatchMgmt::EXT_SRC_PORT
    src.port.must_equal JSSTestHelper::PatchMgmt::EXT_SRC_PORT
  end

  it 'can be enabled and disabled' do
    src.enable
    src.enabled?.must_be_instance_of TrueClass
    src.disable
    src.enabled?.must_be_instance_of FalseClass
  end

  it 'can enable and disable ssl' do
    src.disable_ssl
    src.ssl_enabled?.must_be_instance_of FalseClass
    src.enable_ssl
    src.ssl_enabled?.must_be_instance_of TrueClass
  end

  it 'can update changes to the server' do
    src.update
  end

  it 'can be fetched by name' do
    JSSTestHelper::PatchMgmt.refetch_external_src
    src.must_be_instance_of JSS::PatchExternalSource
  end

  it 'tells us its host' do
    src.host_name.must_equal JSSTestHelper::PatchMgmt::EXT_SRC_NAME
  end

  it 'tells us its port' do
    src.port.must_equal JSSTestHelper::PatchMgmt::EXT_SRC_PORT
  end

  it 'tells us if it is enabled' do
    JSS::TRUE_FALSE.must_include src.enabled?
  end

  it 'tells us if ssl is enabled' do
    JSS::TRUE_FALSE.must_include src.ssl_enabled?
  end

end # describe JSS::PatchInternalSource
