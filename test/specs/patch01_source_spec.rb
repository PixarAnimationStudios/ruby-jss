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
