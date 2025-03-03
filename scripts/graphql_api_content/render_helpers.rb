require 'commonmarker'

module RenderHelpers

  @@vale_off_pages = [
    "__DirectiveLocation"
  ]

  def render_html(markdown)
    markdown ? CommonMarker.render_html(markdown) : nil
  end

  def render_of_type(of_type, size = "medium")
    if of_type["ofType"]
      render_of_type(of_type["ofType"])
    else
      if of_type["name"]
        <<~HTML
          <a href="/docs/apis/graphql/schemas/#{of_type['name'].downcase}" class="pill pill--#{of_type['kind'].downcase} pill--normal-case pill--#{size}" title="Go to #{of_type['kind']} #{of_type['name']}"><code>#{of_type["name"]}</code></a>
        HTML
      else
        of_type["kind"]
      end
    end
  end
  
  def render_fields(fields)
    if fields.is_a?(Array) && !fields.empty?
      <<~HTML
        <table class="responsive-table responsive-table--single-column-rows">
          <thead>
            <th>
              <h2 data-algolia-exclude>Fields</h2>
            </th>
          </thead>
          <tbody>
            #{
              fields.map {
                |field|
                <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
                  <tr>
                    <td>
                      <h3 class="is-small has-pills">
                        <code>#{field["name"]}</code>
                        #{render_of_type(field["type"])}
                        #{field["isDeprecated"] ? '<span class="pill pill--deprecated"><code>deprecated</code></span>' : ""}
                      </h3>
                      #{field["deprecationReason"] ? "<p><em>Deprecated: #{field["deprecationReason"]}</em></p>" : nil}
                      #{field["description"] ? "#{render_html(field["description"])}" : nil}
                      #{render_field_args(field["args"])}
                    </td>
                  </tr>
                HTML
              }.join('')
            }
          </tbody>
        </table>
      HTML
    end
  end
  
  def render_field_args(args)
    if args.is_a?(Array) && !args.empty?
      <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
        <div>
          <details>
            <summary>Arguments</summary>
            <table class="responsive-table responsive-table--single-column-rows">
              <tbody>
                #{
                  args.map {
                    |arg|
                    <<~HTML
                      <tr>
                        <td>
                          <h4 class="is-small has-pills no-margin">
                            <code>#{arg["name"]}</code>
                            #{render_of_type(arg["type"])}
                            #{!arg["defaultValue"] ? '<span class="pill pill--required pill--normal-case"><code>required</code></span>' : ""}
                          </h4>
                          #{arg["description"] && "#{render_html(arg["description"])}"}
                          #{arg["defaultValue"] && "<p class=\"no-margin\">Default value: <code>#{arg["defaultValue"]}</code></p>"}
                        </td>
                      </tr>
                    HTML
                  }.join('')
                }
              </tbody>
            </table>
          </details>
        </div>
      HTML
    end
  end
  
  def render_possible_types(possible_types)
    if possible_types.is_a?(Array) && !possible_types.empty?
      <<~HTML
        <h2 data-algolia-exclude>Possible Types</h2>
        #{possible_types.map { |possible_type| render_of_type(possible_type, "large") }.join('')}
      HTML
    end
  end
  
  def render_input_fields(input_fields)
    if input_fields.is_a?(Array) && !input_fields.empty?
      <<~HTML
        <table class="responsive-table responsive-table--single-column-rows">
          <thead>
            <th>
              <h2 data-algolia-exclude>Input Fields</h2>
            </th>
          </thead>
          <tbody>
            #{
              input_fields.map {
                |input_field|
                <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
                  <tr>
                    <td>
                      <p>
                        <strong><code>#{input_field["name"]}</code></strong>
                        #{render_of_type(input_field["type"])}
                        #{!input_field["defaultValue"] ? "<span class=\"pill pill--required pill--normal-case pill--medium\">required</span>" : nil}
                      </p>
                      #{input_field["description"] ? "#{render_html(input_field["description"])}" : nil}
                      #{input_field["defaultValue"] ? "<p>Default value: #{input_field["defaultValue"]}</p>" : nil}
                    </td>
                  </tr>
                HTML
              }.join('')
            }
          </tbody>
        </table>
      HTML
    end
  end
  
  def render_interfaces(interfaces)
    if interfaces.is_a?(Array) && !interfaces.empty?
      <<~HTML
        <h2 data-algolia-exclude>Interfaces</h2>
        #{
          interfaces.map {
            |interface|
            render_of_type(interface, "large")
          }.join('')
        }
      HTML
    end
  end
  
  def render_enum_values(enum_values)
    if enum_values.is_a?(Array) && !enum_values.empty?
      <<~HTML
        <table class="responsive-table responsive-table--single-column-rows">
          <thead>
            <th>
              <h2 data-algolia-exclude>ENUM Values</h2>
            </th>
          </thead>
          <tbody>
            #{
              enum_values.map {
                |enum_value|
                <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
                  <tr>
                    <td>
                      <p>
                        <strong><code>#{enum_value["name"]}</code></strong>
                        #{enum_value["isDeprecated"] ? "<span class=\"pill pill--deprecated\">deprecated</span>" : nil}
                      </p>
                      #{enum_value["description"] ? "#{render_html(enum_value["description"])}" : nil}
                      #{enum_value["deprecationReason"] ? "<p>Deprecated: #{enum_value["deprecationReason"]}</p>" : nil}
                    </td>
                  </tr>
                HTML
              }.join("")
            }
          </tbody>
        </table>
      HTML
    end
  end
  
  def render_pill(name, size = "medium")
    if name
      <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
        <span class="pill pill--#{name.downcase} pill--normal-case pill--#{size.downcase}">
          <code>#{name}</code>
        </span>
      HTML
    end
  end

  def render_page(schema_type_data)
    name = schema_type_data["name"]
    fields = render_fields(schema_type_data["fields"])
    input_fields = render_input_fields(schema_type_data["inputFields"])
    possible_types = render_possible_types(schema_type_data["possibleTypes"])
    interfaces = render_interfaces(schema_type_data["interfaces"])
    enum_values = render_enum_values(schema_type_data["enumValues"])
    valeOff = @@vale_off_pages.any? { |page_name| page_name == name }

    page_content = <<~HTML.strip
      <!--
        _____   ____    _   _  ____ _______   ______ _____ _____ _______ 
        |  __ \ / __ \  | \ | |/ __ \__   __| |  ____|  __ \_   _|__   __|
        | |  | | |  | | |  \| | |  | | | |    | |__  | |  | || |    | |   
        | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |   
        | |__| | |__| | | |\  | |__| | | |    | |____| |__| || |_   | |   
        |_____/ \____/  |_| \_|\____/  |_|    |______|_____/_____|  |_|   
        This file is auto-generated by script/generate_graphql_api_content.sh,
        please build the schema.json by running `rails api:graph:export`
        with https://github.com/buildkite/buildkite/,
        replace the content in data/graphql_data_schema.json
        and run the generation script `./scripts/generate-graphql-api-content.sh`.
      -->
      #{valeOff ? "<!-- vale off -->" : nil}
      <h1 class="has-pills" data-algolia-exclude>#{name}#{render_pill(schema_type_data["kind"], "large")}</h1>

      #{render_html(schema_type_data["description"])}

      {:notoc}

      #{fields}

      #{input_fields}

      #{interfaces}

      #{possible_types}
      
      #{enum_values}
      #{valeOff ? "<!-- vale on -->" : nil}
    HTML

    page_content + "\n"
  end
end