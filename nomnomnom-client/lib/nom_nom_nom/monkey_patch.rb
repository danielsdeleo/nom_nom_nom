#--
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


###############################################################################
# Chef's Resource#to_text keeps a blacklist of instance variables to skip
# when generating the text representation of the resource. Add a few more.
###############################################################################

[:@immediate_notifications, :@delayed_notifications, :@updated, :@updated_by_last_action].each do |ivar|
  Chef::Resource::HIDDEN_IVARS << ivar unless Chef::Resource::HIDDEN_IVARS.include?(ivar)
end
