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

describe JSS::APIConnection do

  ##### Constants

  TEST_CONNECTION_NAME = 'testconnection'.freeze

  ##### Specs

  # this happens before each 'it' block below.
  before do
    @newcon = JSS::APIConnection.new(
      server: JSS.api.hostname,
      user: JSS.api.jss_user,
      pw: JSSTestHelper::Auth.api_pw(server: nil, port: nil, user: nil),
      name: TEST_CONNECTION_NAME
    )
  end

  it 'can be created' do
    @newcon.must_be_instance_of JSS::APIConnection
  end

  it 'has a settable name at creation' do
    @newcon.name.must_equal TEST_CONNECTION_NAME
  end

  it 'can be made default' do
    JSS.use_api_connection @newcon
    JSS.api.name.must_equal TEST_CONNECTION_NAME
  end

end
