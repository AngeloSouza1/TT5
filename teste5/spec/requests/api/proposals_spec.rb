# spec/api/proposals_controller_spec.rb

require 'rails_helper'

RSpec.describe Api::ProposalsController, type: :controller do
  describe 'POST #organize_conference' do
    it 'retorna uma resposta de sucesso' do
      post :organize_conference
      expect(response).to have_http_status(:success)
    end
  
  end
end
