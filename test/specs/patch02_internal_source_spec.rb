### Copyright 2019 Pixar

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
