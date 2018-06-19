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

describe JSS::PatchTitle do

  ##### Constants

  TEST_NAME = 'rubyjss-testPatchTitle'.freeze

  ##### Class Methods

  # this effectively makes the tests run in the order defined, which is
  # needed in this situattion.
  def self.test_order
    :alpha
  end

  def self.unused_name_ids
    return @unused_name_ids if @unused_name_ids
    src = JSS::PatchInternalSource.fetch id: 1
    @unused_name_ids = src.available_name_ids - JSS::PatchTitle.all_name_ids
  end

  def self.test_title
    @test_title ||= JSS::PatchTitle.make name: TEST_NAME
  end

  def self.refetch
    @test_title = JSS::PatchTitle.fetch name: TEST_NAME
  end

  def self.test_version
    @tv ||= test_title.versions.values.sample
  end

  ##### Instance Methods

  def tt
    self.class.test_title
  end

  def tv
    self.class.test_version
  end

  def prompt_for_name_id
    puts '***************************'
    puts 'Enter an unused Patch Title name_id for testing.'
    puts 'Must be one of the following:'
    unused_name_ids = self.class.unused_name_ids
    unused_name_ids.each { |ni| puts "  #{ni}" }
    puts
    print 'which one?: '
    chosen = $stdin.gets.chomp
    until unused_name_ids.include? chosen
      puts 'that one isnt on the list'
      print 'which one?: '
      chosen = $stdin.gets.chomp
    end
    chosen
  end

  ##### Specs

  it 'can delete crufty objects from earlier tests' do
    break unless JSS::PatchTitle.all_names(:refresh).include? TEST_NAME
    puts 'Deleting crufty Patch Title from Previous Tests'
    deleted = JSS::PatchTitle.delete JSS::PatchTitle.map_all_ids_to(:name).invert[TEST_NAME]
    deleted.must_be_instance_of Array
    deleted.must_be_empty
    JSS::PatchTitle.all_names(:refresh).wont_include TEST_NAME
  end

  it 'can list all patch titles' do
    JSS::PatchTitle.all.must_be_instance_of Array
    break if JSS::PatchTitle.all.empty?
    JSS::PatchTitle.all.first.must_be_instance_of Hash
    JSS::PatchTitle.all.first[:id].must_be_kind_of Integer
  end

  it 'can list all patch title name_ids' do
    JSS::PatchTitle.all_names.must_be_instance_of Array
    break if JSS::PatchTitle.all_names.empty?
    JSS::PatchTitle.all_names.first.must_be_instance_of String
  end

  it 'can list source_ids in use' do
    JSS::PatchTitle.all_source_ids.must_be_instance_of Array
    break if JSS::PatchTitle.all_source_ids.empty?
    JSS::PatchTitle.all_source_ids.first.must_be_kind_of Integer
  end

  # TODO: simplify this when we aren't reading the data via
  # XMLWorkaround
  it 'can get a patch report' do
    break if JSS::PatchTitle.all.empty?

    report = JSS::PatchTitle.patch_report JSS::PatchTitle.all_ids.sample
    report.must_be_instance_of Hash
    report.keys.must_include :versions
    report[:versions].must_be_instance_of Hash
    break if report[:versions].empty?

    vers_name = report[:versions].keys.sample
    vers_name.must_be_instance_of String
    report[:versions][vers_name].must_be_instance_of Array
    break if report[:versions][vers_name].empty?

    client = report[:versions][vers_name].sample
    client.must_be_instance_of Hash
    client[:id].must_be_kind_of Integer
  end

  it 'can be made' do
    self.class.test_title.name == TEST_NAME
  end

  it 'must have a source_id before a name_id' do
    proc { self.class.test_title.name_id = 'foo' }.must_raise JSS::NoSuchItemError
  end

  it 'cannot be created without a name_id' do
    proc { tt.create }.must_raise JSS::InvalidDataError
    tt.source_id = 1
    proc { tt.create }.must_raise JSS::InvalidDataError
  end

  it 'can be created with a name_id' do
    tt.name_id = prompt_for_name_id
    new_id = tt.create
    new_id.must_equal tt.id
    JSS::PatchTitle.all_names(:refresh).must_include TEST_NAME
    tt.in_jss.must_be_instance_of TrueClass
  end

  it 'can be fetched by name' do
    id = tt.id
    self.class.refetch
    tt.id.must_equal id
  end

  it 'has an array of Version objects' do
    tt.versions.must_be_instance_of Hash
    tv.must_be_instance_of JSS::PatchTitle::Version
  end

  it 'has no packages assigned by default' do
    tv.package_assigned?.must_be_instance_of FalseClass
    tt.versions_with_packages.size.must_be :==, 0
  end

  it 'cannot assign a non-existing package to a version' do
    proc { tv.package = 'there should be no such package here' }.must_raise JSS::NoSuchItemError
  end

  it 'can assign a package to a version' do
    pkg = JSS::Package.all.sample
    tv.package = pkg[:id]
    tv.package_name.must_equal pkg[:name]
  end

  it 'can get a patch report from a version' do
    tv.patch_report.must_be_instance_of Hash
  end

  it 'can set email notifications' do
    tt.email_notification = true
  end

  it 'can set web notifications' do
    tt.web_notification = true
  end

  it 'can update the JSS with changes' do
    tt.update
    tt.need_to_update.must_be_instance_of FalseClass
  end

  it 'has the saved values when re-fetched' do
    self.class.refetch
    tt.email_notification.must_be_instance_of TrueClass
    tt.web_notification.must_be_instance_of TrueClass
    tt.versions_with_packages.size.must_be :==, 1
  end

  it 'can be deleted' do
    tt = self.class.test_title
    tt.delete
    tt.in_jss.must_be_instance_of FalseClass
    JSS::PatchTitle.all_names(:refresh).wont_include TEST_NAME
  end

end
