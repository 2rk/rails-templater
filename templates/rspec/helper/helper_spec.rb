require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the <%= class_name %>Helper. For example:
#
# describe <%= class_name %>Helper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
<% module_namespacing do -%>
describe <%= class_name %>Helper do

end
<% end -%>