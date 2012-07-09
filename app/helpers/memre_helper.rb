module MemreHelper

  def get_properties_json
    prop_map = {}
    MembraneProperty.all.each do |mp|
      prop_map[mp.name] = {
        'measurement_techniques' => mp.measurement_techniques.split('|'),
        'type_of_property' => mp.property_type
      }
      %w{description property_units qualifier1 qualifier2 qualifier3}.each {|key| prop_map[mp.name][key] = mp.send(key)}
    end
    prop_map.to_json.html_safe
  end

end
