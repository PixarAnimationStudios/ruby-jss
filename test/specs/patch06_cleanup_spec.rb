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

describe JSSTestHelper do

  # this effectively makes the tests run in the order defined, which is
  # needed in this situattion.
  def self.test_order
    :alpha
  end

  it 'can delete external source' do
    gone = JSSTestHelper::PatchMgmt.delete_external_src
    gone.must_be_instance_of Array
    gone.must_be_empty
  end

  it 'can delete patch policy' do
    gone = JSSTestHelper::PatchMgmt.delete_policy
    gone.must_be_instance_of Array
    gone.must_be_empty
  end

  it 'can delete patch title' do
    gone = JSSTestHelper::PatchMgmt.delete_title
    gone.must_be_instance_of Array
    gone.must_be_empty
  end

end
