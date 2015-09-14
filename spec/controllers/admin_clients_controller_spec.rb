require 'rails_helper'

RSpec.describe Admin::ClientsController, type: :controller do

  it_behaves_like 'admin users controller', :client

end
