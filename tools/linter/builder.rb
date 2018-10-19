# Copyright 2018 Google Inc.
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

# Load everything from MM root.
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../../')
Dir.chdir(File.join(File.dirname(__FILE__), '../../'))

require 'tools/linter/discovery'
require 'tools/linter/api'

require 'api/product'
require 'api/resource'
require 'api/type'

COMPUTE_DISCOVERY_URL = 'https://www.googleapis.com/discovery/v1/apis/compute/v1/rest'.freeze

module Api
  class Object
    # Create a setter if the setter doesn't exist
    # Yes, this isn't pretty and I apologize
    def method_missing(method_name, *args)
      matches = /([a-z_]*)=/.match(method_name)
      super unless matches
      create_setter(matches[1])
      method(method_name.to_sym).call(*args)
    end

    def create_setter(variable)
      self.class.define_method("#{variable}=") { |val| instance_variable_set("@#{variable}", val) }
    end
  end
end

product = Api::Product.new
discovery = Discovery.new(COMPUTE_DISCOVERY_URL)

product.name = 'Google Compute Engine'
product.prefix = 'gcompute'
product.scopes = ['https://www.googleapis.com/auth/compute']
product.objects = []

discovery.resources.map { |x| discovery.resource(x) }.each do |obj|
  resource = Api::Resource.new
  resource.name = obj.schema.dig('id')
  resource.kind = obj.schema.dig('properties', 'kind', 'default')
  resource.description = obj.schema.dig('description')
  resource.properties = []
  obj.schema.dig('properties').reject { |k, v| k == 'kind' }.each do |k, v|
    prop = Api::Type::String.new
    prop.name = k
    resource.properties = resource.properties.append(prop)
  end
  product.objects.append(resource)
end

File.write('output.yaml', product.to_yaml)