require 'json'

class Schema
  def initialize(schema_json)
    schema_hash = JSON.parse(schema_json)
    
    @all_schema_types = schema_hash["data"]["__schema"]["types"]
    @type_sets_default = {
      "query_types" => [],
      "object_types" => [],
      "scalar_types" => [],
      "interface_types" => [],
      "enum_types" => [],
      "input_object_types" => [],
      "union_types" => []
    }
  end

  def type_sets
    type_sets = @type_sets_default
    query_object_type = nil

    @all_schema_types.each do |type|
      key = "#{type["kind"].downcase}_types"
      type_sets[key].push type
    end

    query_object_type = type_sets["object_types"].find { |object_type| object_type["name"] == "Query" }
    type_sets["query_types"] = query_object_type && query_object_type["fields"]

    type_sets
  end
end
