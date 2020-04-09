### Copyright 2020 Pixar

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

  # CONSTANTS

  POLICY_NAME = 'rubyjss-testPolicy'.freeze

  # CLASS METHODS

  # this effectively makes the tests run in the order defined
  def self.test_order
    :alpha
  end

  def self.policy(refresh = false)
    @policy = nil if refresh
    return @policy if @policy
    @policy =
      if JSS::Policy.all_names.include? POLICY_NAME
        JSS::Policy.fetch name: POLICY_NAME
      else
        JSS::Policy.make name: POLICY_NAME
      end
  end

  def self.delete_policy
    return [] unless JSS::Policy.all_names(:refresh).include? POLICY_NAME
    JSS::Policy.delete JSS::Policy.map_all_ids_to(:name).invert[POLICY_NAME]
  end

  # SPECS

  it 'can delete crufty policies from earlier tests' do
    deleted = self.class.delete_policy
    deleted.must_be_instance_of Array
    deleted.must_be_empty
    JSS::Policy.all_names(:refresh).wont_include POLICY_NAME
  end

  it 'can be made' do
    # see .policy class method above
    self.class.policy.must_be_instance_of JSS::Policy
    self.class.policy.in_jss.must_be_instance_of FalseClass
  end

  it 'can set maintenance tasks' do
    pol = self.class.policy
    pol.verify_startup_disk = true
    pol.permissions_repair = false
    pol.recon = true
    pol.fix_byhost = false
    pol.reset_name = true
    pol.flush_system_cache = false
    pol.install_cached_pkgs = true
    pol.flush_user_cache = false
  end

  it 'can be created ' do
    pol = self.class.policy
    pol.create
    JSS::Policy.all_names(:refresh).must_include POLICY_NAME
    pol.in_jss.must_be_instance_of TrueClass
  end

  it 'can be fetched by name' do
    id = self.class.policy.id
    self.class.policy :refresh
    self.class.policy.id.must_equal id
  end

  it 'still has correct maintenance tasks' do
    pol = self.class.policy
    pol.verify_startup_disk.must_be_instance_of TrueClass
    pol.permissions_repair.must_be_instance_of FalseClass
    pol.recon.must_be_instance_of TrueClass
    pol.fix_byhost.must_be_instance_of FalseClass
    pol.reset_name.must_be_instance_of TrueClass
    pol.flush_system_cache.must_be_instance_of FalseClass
    pol.install_cached_pkgs.must_be_instance_of TrueClass
    pol.flush_user_cache.must_be_instance_of FalseClass
  end

  it 'can be deleted' do
    self.class.policy.delete.must_equal :deleted
    JSS::Policy.all_names(:refresh).wont_include POLICY_NAME
  end

end
