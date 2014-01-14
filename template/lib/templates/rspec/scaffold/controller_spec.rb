require 'spec_helper'

<% module_namespacing do -%>
describe <%= controller_class_name %>Controller do
  render_views
  common_lets

  before :all do
    Fracture.define_selector :new_<%= file_name %>_link
    Fracture.define_selector :cancel_new_<%= file_name %>_link
    Fracture.define_selector :edit_<%= file_name %>_link
    Fracture.define_selector :cancel_edit_<%= file_name %>_link
  end

  context 'not logged in' do
    before { sign_out user }

    {index: :get, show: :get, new: :get, create: :post, edit: :get, update: :put, destroy: :delete}.each do |v, m|
      it "#{m} #{v} should logout" do
        self.send(m, v, id: <%= file_name %>)
        should redirect_to new_user_session_path
      end
    end
  end

  context 'logged in as user' do
    before { sign_in user }

<% unless options[:singleton] -%>
    describe 'GET index' do
      before do
        <%= file_name %>
        <%= file_name %>_other
        get :index
      end

      it { should assign_to(:<%= table_name %>).with([<%= file_name %>]) }
      it { should render_template :index }
      it { should have_only_fractures(:new_<%= file_name %>_link) }
    end

<% end -%>
    describe 'GET show' do
      before { get :show, id: <%= file_name %> }

      it { should assign_to(:<%= file_name %>).with(<%= file_name %>) }
      it { should render_template :show }
      it { should have_only_fractures(:edit_<%= file_name %>_link) }
    end

    describe 'GET new' do
      before { get :new }

      it { should assign_to(:<%= file_name %>).with_kind_of(<%= class_name %>) }
      #it { should assign_to('<%= file_name %>.parent').with(parent) }
      it { should render_template :new }
      it { should have_only_fractures :cancel_new_<%= file_name %>_link }
      it { should have_a_form.that_is_new.with_path_of(<%= table_name %>_path)}
    end

    describe 'POST create' do
      context 'valid' do
        before do
          <%= class_name %>.any_instance.stub(:valid?).and_return(true)
          post :create
        end

        it { should redirect_to <%= file_name %>_path(<%= class_name %>.last) }
        it { should assign_to(:<%= file_name %>).with(<%= class_name %>.last) }
        #it { should assign_to('<%= file_name %>.parent').with(parent) }
      end

      context 'invalid' do
        before do
          <%= class_name %>.any_instance.stub(:valid?).and_return(false)
          post :create
        end

        it { should assign_to(:<%= file_name %>).with_kind_of(<%= class_name %>) }
        #it { should assign_to('<%= file_name %>.parent').with(parent) }
        it { should render_template :new }
        it { should have_only_fractures :cancel_new_<%= file_name %>_link }
        it { should have_a_form.that_is_new.with_path_of(<%= table_name %>_path)}
      end
    end

    describe 'GET edit' do
      before { get :edit, id: <%= file_name %> }

      it { should assign_to(:<%= file_name %>).with(<%= file_name %>) }
      it { should render_template :edit }
      it { should have_only_fractures :cancel_edit_<%= file_name %>_link }
      it { should have_a_form.that_is_edit.with_path_of(<%= file_name %>_path) }
    end

    describe 'PUT update' do
      context 'valid' do
        before do
          <%= class_name %>.any_instance.stub(:valid?).and_return(true)
          put :update, id: <%= file_name %>
        end

        it { should assign_to(:<%= file_name %>).with(<%= file_name %>) }
        it { should redirect_to <%= file_name %>_path(<%= file_name %>) }
      end
      context 'invalid' do
        before do
          <%= file_name %>
          <%= class_name %>.any_instance.stub(:valid?).and_return(false)
          put :update, id: <%= file_name %>
        end

        it { should assign_to(:<%= file_name %>).with(<%= file_name %>) }
        it { should render_template :edit }
        it { should have_only_fractures :cancel_edit_<%= file_name %>_link }
        it { should have_a_form.that_is_edit.with_path_of(<%= file_name %>_path) }
      end
    end

    describe 'DELETE destroy' do
      before { delete :destroy, id: <%= file_name %> }

      it { expect(<%= class_name %>.find_by_id(<%= file_name %>.id)).to be_nil }
      it { should redirect_to <%= index_helper %>_path }
    end
  end
end
<% end -%>
