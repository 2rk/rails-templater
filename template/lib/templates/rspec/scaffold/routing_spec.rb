require 'spec_helper'

<% module_namespacing do -%>
describe <%= controller_class_name %>Controller do
  describe 'routing' do

<% unless options[:singleton] -%>
    it('routes to #index') { get('/<%= ns_table_name %>').should route_to('<%= ns_table_name %>#index') }
<% end -%>
    it('routes to #new') { get('/<%= ns_table_name %>/new').should route_to('<%= ns_table_name %>#new') }
    it('routes to #show') { get('/<%= ns_table_name %>/1').should route_to('<%= ns_table_name %>#show', id: '1') }
    it('routes to #edit') { get('/<%= ns_table_name %>/1/edit').should route_to('<%= ns_table_name %>#edit', id: '1') }
    it('routes to #create') { post('/<%= ns_table_name %>').should route_to('<%= ns_table_name %>#create') }
    it('routes to #update') { put('/<%= ns_table_name %>/1').should route_to('<%= ns_table_name %>#update', id: '1') }
    it('routes to #destroy') { delete('/<%= ns_table_name %>/1').should route_to('<%= ns_table_name %>#destroy', id: '1') }
  end
end
<% end -%>
