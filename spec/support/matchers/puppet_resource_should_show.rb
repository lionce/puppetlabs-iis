# The property named `property_name` should be shown in the output of puppet resource. If a non-nil value is specified, the matcher only
# matches if the value is presented (quoted, or unquoted)
def puppet_resource_should_show(property_name, value, result)
  it "should report the correct #{property_name} value" do
    puts '*' * 100
    puts 'date din resource show'

    puts result.stdout
    regex = if value.nil?
              %r{(#{property_name})(\s*)(=>)(\s*)}
            elsif value.is_a?(Array)
              %r{(#{property_name})(\s*)(=>)(\s*)(\[#{value.sort.map! { |v| "'#{v}'" }.join(', ')}\])}i
            else
              %r{(#{property_name})(\s*)(=>)(\s*)('#{Regexp.escape(value)}'|#{Regexp.escape(value)})}i
            end

    expect(result.stdout).to match(regex)
  end
end
