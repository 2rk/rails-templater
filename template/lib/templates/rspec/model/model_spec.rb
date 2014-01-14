require 'spec_helper'

<% module_namespacing do -%>
describe <%= class_name %> do

  common_lets

  # define the <%= file_name %>, <%= file_name %>_other,... instances in
  # spec/support/common_lets.rb
  it { expect(<%= file_name %>).to be_valid }
#  it { expect(<%= file_name %>_other).to be_valid }

end
<% end -%>
