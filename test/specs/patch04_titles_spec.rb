### Copyright 2022 Pixar

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

  ##### Class Methods

  # this effectively makes the tests run in the order defined, which is
  # needed in this situattion.
  def self.test_order
    :alpha
  end

  ##### Instance Methods

  # shortcuts

  def tt
    JSSTestHelper::PatchMgmt.title
  end

  def tv
    tt.versions[JSSTestHelper::PatchMgmt.version_key]
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

  it 'can delete crufty title from earlier tests' do
    deleted = JSSTestHelper::PatchMgmt.delete_title
    deleted.must_be_instance_of Array
    deleted.must_be_empty
    JSS::PatchTitle.all_names(:refresh).wont_include JSSTestHelper::PatchMgmt::PATCH_TITLE_NAME
  end

  it 'can list all patch title source_name_ids' do
    source_name_ids = JSS::PatchTitle.all_source_name_ids
    source_name_ids.must_be_instance_of Array
    break if source_name_ids.empty?
    source_name_ids.first.must_be_instance_of String
  end

  it 'can list source_ids in use' do
    srcids = JSS::PatchTitle.all_source_ids
    srcids.must_be_instance_of Array
    break if srcids.empty?
    srcids.first.must_be_kind_of Integer
  end

  it 'cannot be made without a source and name_id' do
    proc {
      JSS::PatchTitle.make name: JSSTestHelper::PatchMgmt::PATCH_TITLE_NAME
    }.must_raise JSS::MissingDataError

    proc {
      JSS::PatchTitle.make name: JSSTestHelper::PatchMgmt::PATCH_TITLE_NAME,
      source: 'Foobar'
    }.must_raise JSS::MissingDataError

    proc {
      JSS::PatchTitle.make name: JSSTestHelper::PatchMgmt::PATCH_TITLE_NAME,
      name_id: 'Foobar'
    }.must_raise JSS::MissingDataError
  end

  it 'must check that the source exists' do
    proc {
      JSS::PatchTitle.make(
        name: JSSTestHelper::PatchMgmt::PATCH_TITLE_NAME,
        source: 'Foobar',
        name_id: 'FoobarNoSuchNameId'
      )
    }.must_raise JSS::NoSuchItemError
  end

  it 'must check that the name_id is available in the source' do
    proc {
      JSS::PatchTitle.make(
        name: JSSTestHelper::PatchMgmt::PATCH_TITLE_NAME,
        source: JSSTestHelper::PatchMgmt::PATCH_TITLE_SOURCE,
        name_id: 'FoobarNoSuchNameId'
      )
    }.must_raise JSS::NoSuchItemError
  end

  it 'can be made with name, source, and name_id' do
    tt.must_be_instance_of JSS::PatchTitle
  end

  it 'can be created' do
    tt.create
    JSS::PatchTitle.all_names(:refresh).must_include JSSTestHelper::PatchMgmt::PATCH_TITLE_NAME
    tt.in_jss.must_be_instance_of TrueClass
  end

  it 'can be fetched by souce and name_id' do
    id = tt.id
    JSSTestHelper::PatchMgmt.title(:refetch)
    tt.id.must_equal id
  end

  # TODO: simplify this when we aren't reading the data via
  # XMLWorkaround
  it 'can get a patch report' do
    report = JSS::PatchTitle.patch_report tt.id
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
    JSSTestHelper::PatchMgmt.title :refetch
    tt.email_notification.must_be_instance_of TrueClass
    tt.web_notification.must_be_instance_of TrueClass
    verss = tt.versions_with_packages
    verss.size.must_be :==, 1
    verss.keys.first.must_equal tv.version
  end

end
