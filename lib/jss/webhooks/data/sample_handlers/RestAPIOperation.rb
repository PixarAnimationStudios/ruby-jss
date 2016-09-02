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

JSSWebHooks.event_handler do |event|
  eobject = event.event_object
  whook = event.webhook

  REPORT_ACTIONS = {
    'PUT' => 'update',
    'POST' => 'create',
    'DELETE' => 'delete'
  }.freeze unless defined? REPORT_ACTIONS

  action = REPORT_ACTIONS[eobject.restAPIOperationType]

  return nil unless action

  puts <<-ENDMSG
The JSS WebHook named '#{whook.name}' was just triggered.
It indicates that Casper user '#{eobject.authorizedUsername}' just used the JSS API to #{action}
the JSS #{eobject.objectTypeName} named '#{eobject.objectName}' (id #{eobject.objectID})
ENDMSG
end
