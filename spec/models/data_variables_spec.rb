require "rails_helper"

RSpec.describe DataVariables do
  context ".set" do
    it "sets env variables for all the data/*.yml files" do
      data_variables = described_class.set


    end
  end

  it "excludes *.schema.yml files"

  it "excludes any other files that are not in yml format"
end
