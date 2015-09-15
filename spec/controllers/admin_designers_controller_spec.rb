require 'rails_helper'

RSpec.describe Admin::DesignersController, type: :controller do

  it_behaves_like 'admin users controller', :designer

end

