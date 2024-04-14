require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:address) { FactoryBot.build(:address) }

  context 'Should validate' do
    it 'with street, city, and zip present' do
      expect(address).to be_valid
    end  
  end

  context 'Should not be valid' do
    it 'when street is not present' do
      address.street = nil
      expect(address).not_to be_valid
    end
  end
end
