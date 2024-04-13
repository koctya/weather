require 'rails_helper'

RSpec.describe "addresses/edit", type: :view do
  let(:address) {
    Address.create!(
      street: "MyString",
      city: "MyString",
      state: "MyString",
      zip: "MyString"
    )
  }

  before(:each) do
    assign(:address, address)
  end

  it "renders the edit address form" do
    render

    assert_select "form[action=?][method=?]", address_path(address), "post" do

      assert_select "input[name=?]", "address[street]"

      assert_select "input[name=?]", "address[city]"

      assert_select "input[name=?]", "address[state]"

      assert_select "input[name=?]", "address[zip]"
    end
  end
end
