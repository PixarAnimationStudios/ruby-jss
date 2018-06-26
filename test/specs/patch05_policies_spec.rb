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

describe JSS::PatchPolicy do
  ##### Constants

  DEADLINE_DAYS = 17

  ##### Class Methods

  # this effectively makes the tests run in the order defined, which is
  # needed in this situattion.
  def self.test_order
    :alpha
  end

  ##### Specs

  it 'can delete crufty patch policies from earlier tests' do
    deleted = JSSTestHelper::PatchMgmt.delete_policy
    deleted.must_be_instance_of Array
    deleted.must_be_empty
    JSS::PatchPolicy.all_names(:refresh).wont_include JSSTestHelper::PatchMgmt::PATCHCPOL_NAME
  end

  it 'cannot be made without a patch title' do
    proc { JSS::PatchPolicy.make name: JSSTestHelper::PatchMgmt::PATCHCPOL_NAME }.must_raise JSS::MissingDataError
  end

  it 'can be made with a patch title' do
    # JSSTestHelper::PatchMgmt.policy will do a make with our test title the
    # first time its called
    JSSTestHelper::PatchMgmt.policy.must_be_instance_of JSS::PatchPolicy
    JSSTestHelper::PatchMgmt.policy.in_jss.must_be_instance_of FalseClass
  end

  it 'cannot be created without a target_version' do
    proc { JSSTestHelper::PatchMgmt.policy.create }.must_raise JSS::MissingDataError
  end

  it 'will not accept a target_version that has no package' do
    title = JSSTestHelper::PatchMgmt.title
    badvers = (title.versions.keys - title.versions_with_packages.keys).sample
    proc { JSSTestHelper::PatchMgmt.policy.target_version = badvers }.must_raise JSS::UnsupportedError
  end

  it 'can be created with a target_version that has a package' do

    JSSTestHelper::PatchMgmt.policy.target_version = JSSTestHelper::PatchMgmt.version_key
    JSSTestHelper::PatchMgmt.policy.create
    JSS::PatchPolicy.all_names(:refresh).must_include JSSTestHelper::PatchMgmt::PATCHCPOL_NAME
    JSSTestHelper::PatchMgmt.policy.in_jss.must_be_instance_of TrueClass
  end

  it 'can be fetched by name' do
    id = JSSTestHelper::PatchMgmt.policy.id
    JSSTestHelper::PatchMgmt.policy :refresh
    JSSTestHelper::PatchMgmt.policy.id.must_equal id
  end

  it 'can be put into self service' do
    JSSTestHelper::PatchMgmt.policy.add_to_self_service
    JSSTestHelper::PatchMgmt.policy.in_self_service?.must_be_instance_of TrueClass
  end

  it 'interprets non-positive deadline as no deadline' do
    JSSTestHelper::PatchMgmt.policy.deadline = 0
    JSSTestHelper::PatchMgmt.policy.deadline.must_equal JSS::PatchPolicy::NO_DEADLINE
    JSSTestHelper::PatchMgmt.policy.deadline = -2
    JSSTestHelper::PatchMgmt.policy.deadline.must_equal JSS::PatchPolicy::NO_DEADLINE
  end

  it 'can take a positive deadline value' do
    JSSTestHelper::PatchMgmt.policy.deadline = DEADLINE_DAYS
    JSSTestHelper::PatchMgmt.policy.deadline.must_equal DEADLINE_DAYS
  end

  it 'interprets negative grace period value as zero' do
    JSSTestHelper::PatchMgmt.policy.grace_period = -12
    JSSTestHelper::PatchMgmt.policy.grace_period.must_equal 0
  end

  it 'can take a non-negative grace period value' do
    JSSTestHelper::PatchMgmt.policy.grace_period = 0
    JSSTestHelper::PatchMgmt.policy.grace_period.must_equal 0
    JSSTestHelper::PatchMgmt.policy.grace_period = 16
    JSSTestHelper::PatchMgmt.policy.grace_period.must_equal 16
  end

  it 'can save changes' do
    JSSTestHelper::PatchMgmt.policy.update.must_equal JSSTestHelper::PatchMgmt.policy.id
    JSSTestHelper::PatchMgmt.policy :refresh
    JSSTestHelper::PatchMgmt.policy.grace_period.must_equal 16
    JSSTestHelper::PatchMgmt.policy.deadline.must_equal DEADLINE_DAYS
    JSSTestHelper::PatchMgmt.policy.in_self_service?.must_be_instance_of TrueClass
  end

end
