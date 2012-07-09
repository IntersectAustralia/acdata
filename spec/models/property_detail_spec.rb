require 'spec_helper'

describe PropertyDetail do

  it { should validate_presence_of :name }
  it { should validate_presence_of :measurement_technique }
end
