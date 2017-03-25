### Copyright 2017 Pixar

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

module JSSWebHooks

  MANUAL_CERTIFICATE = '/Users/Shared/pixar.com.crt'.freeze
  MANUAL_KEY = '/Users/Shared/pixar.com.key'.freeze
  CERT = OpenSSL::X509::Certificate.new File.read MANUAL_CERTIFICATE || nil
  PKEY = OpenSSL::PKey::RSA.new File.read MANUAL_KEY || nil

  # Sinatra Server
  class Server < Sinatra::Base

    DEFAULT_SERVER_ENGINE = :webrick
    DEFAULT_PORT = 8443

    configure do
      server_engine = JSSWebHooks::CONFIG.server_engine || DEFAULT_SERVER_ENGINE
      server_port = JSSWebHooks::CONFIG.server_port || DEFAULT_PORT

      # Sinatra Settings
      enable :logging, :lock
      set :bind, '0.0.0.0'
      set :server, server_engine
      set :port, server_port
    end

    def self.server_settings
      { SSLEnable: true, SSLVerifyClient: OpenSSL::SSL::VERIFY_NONE, SSLCertificate: CERT, SSLPrivateKey: PKEY }
    end

  end # class

end # module
