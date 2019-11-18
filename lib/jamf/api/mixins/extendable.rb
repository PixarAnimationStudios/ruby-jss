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

module Jamf

  #
  module Extendable

    # The Array of extensionAttributes converted to a Hash of
    # 'Name' => value
    def ext_attrs
      extensionAttributes.map { |ea| [ea.name, ea.value] }.to_h.freeze
    end

    def ext_attr_names
      extensionAttributes.map(&:name).freeze
    end

    def set_ext_attr(ea_name, new_val)
      raise Jamf::NoSuchItemError, "No ext attr named '#{ea_name}'" unless ext_attr_names.include? ea_name
      eattr = extensionAttributes.select { |ea| ea.name == ea_name }.first
      eattr.send :new_value=, new_val
    end

    def ext_attrs_to_update
      extensionAttributes.select(&:unsaved_changes?)
    end

    def ext_attrs_unsaved_changes
      ext_attrs_to_update.map do |ea|
        [ea.name,
         {
           old: ea.unsaved_changes[:value][:old],
           new: ea.unsaved_changes[:value][:new]
         }]
      end.to_h
    end

    def ext_attrs_unsaved_changes?
      !ext_attrs_to_update.empty?
    end

    def ext_attrs_clear_unsaved_changes
      ext_attrs_to_update.each(&:clear_unsaved_changes)
    end

    def ext_attrs_to_jamf
      ext_attrs_to_update.map(&:to_jamf)
    end

  end # extendable

end # module
