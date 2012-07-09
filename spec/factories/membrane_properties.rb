Factory.define :memre_properties do |f|
  f.name 'Some Property'
  f.property_type 'surface'
  f.description 'the something property'
  f.property_units 'mv'
  f.qualifier1
  f.qualifier2
  f.qualifier3
  f.measurement_techniques 'Technique One|Technique Two'
end

