### Copyright 2016 Pixar
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

  ### An on-the-fly generated, self-signed ssl certificate with
  ### matching private key.
  ###
  class SelfSignedCert
    require 'openssl'
    DFT_C = "US"
    DFT_ST = "California"
    DFT_L = "Emeryville"
    DFT_O = "Pixar"
    DFT_OU = "MacTeam"
    DFT_CN = "localhost"

    attr_reader :private_key, :certificate

    def initialize (args = {})
      args[:c] ||= DFT_C
      args[:st] ||= DFT_ST
      args[:l] ||= DFT_L
      args[:o] ||= DFT_O
      args[:ou] ||= DFT_OU
      args[:cn] ||= DFT_CN

      name = "/C=#{args[:c]}/ST=#{args[:st]}/L=#{args[:l]}/O=#{args[:o]}/OU=#{args[:ou]}/CN=#{args[:cn]}"
      ca   = OpenSSL::X509::Name.parse(name)
      key = OpenSSL::PKey::RSA.new(1024)
      crt = OpenSSL::X509::Certificate.new
      crt.version = 2
      crt.serial  = 1
      crt.subject = ca
      crt.issuer = ca
      crt.public_key = key.public_key
      crt.not_before = Time.now
      crt.not_after  = Time.now + 1 * 365 * 24 * 60 * 60 # 1 year
      @certificate = crt
      @private_key = key
    end # init
  end # class
end # module JSSWebHooks
