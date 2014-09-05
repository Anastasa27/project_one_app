dashboard_hp_spec.rb

require 'pry'

describe("The Dashboard Homepage") do
  it("greets the user") do
    visit("/")
    expect(page).to have_content("Welcome")
  end
end
