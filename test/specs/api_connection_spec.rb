
describe JSS::APIConnection do

  TEST_CONNECTION_NAME = 'testconnection'.freeze

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
