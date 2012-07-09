Given /^I have the usual membrane property types$/ do
  [
      {
          "name" => "Contact Angle",
          "description" => "Test description",
          "measurement_techniques" => "Goniometer Method|Sessile Drop Method|Wilhemy Method",
          "property_type" => "surface",
          "property_units" => "degrees",
          "qualifier1" => "",
          "qualifier2" => "",
          "qualifier3" => nil,
      },
      {
          "name" => "Diffusion Coefficient",
          "description" => "the diffusion coefficient describes the rate of diffusion of particles",
          "measurement_techniques" => "Atomistic Simulation",
          "property_type" => "volumetric",
          "property_units" => "m<sup>2</sup> s<sup>-1</sup>",
          "qualifier1" => "",
          "qualifier2" => "",
          "qualifier3" => nil
      }
  ].each do |attrs|
    MembraneProperty.create(attrs)
  end
end

Then /^I should have a MemRE export for "([^"]*)"$/ do |dataset_name|
  d = Dataset.find_by_name(dataset_name)
  d.memre_export.should_not be_nil
end

Then /^I have exported "([^"]*)" to MemRE/ do |dataset_name|
  d = Dataset.find_by_name(dataset_name)
  Factory(:memre_export, :dataset => d)
end
