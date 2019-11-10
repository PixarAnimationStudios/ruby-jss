# Copyright 2019 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.
#
#
# Copyright 2019 Pixar

#
#    Licensed under the Apache License, Version 2.0 (the "Apache License")
#    with the following modification; you may not use this file except in
#    compliance with the Apache License and the following modification to it:
#    Section 6. Trademarks. is deleted and replaced with:
#
#    6. Trademarks. This License does not grant permission to use the trade
#       names, trademarks, service marks, or product names of the Licensor
#       and its affiliates, except as required to comply with Section 4(c) of
#       the License and to reproduce the content of the NOTICE file.
#
#    You may obtain a copy of the Apache License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the Apache License with the above modification is
#    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied. See the Apache License for the specific
#    language governing permissions and limitations under the Apache License.

module JamfRubyExtensions

  module Hash

    module BackPorts

      empty_hash = {}

      # Ruby 2.5 + has transform_keys
      unless empty_hash.respond_to? :transform_keys
        def transform_keys(&block)
          nh = {}
          each do |k, v|
            nk = yield k
            nh[nk] = v
          end
          nh
        end

        def transform_keys!(&block)
          replace transform_keys(&block)
        end
      end # unless

      # Ruby 2.4 + has transform_values
      unless empty_hash.respond_to? :transform_values
        def transform_values(&block)
          nh = {}
          each do |k, v|
            nv = yield v
            nh[k] = nv
          end
          nh
        end

        def transform_values!(&block)
          replace transform_values(&block)
        end
      end # unless

    end # module

  end # module

end # module
