module InstrumentManagementHelper
  def available_string(instrument)
    text = ''
    if instrument.is_available
      text << '<span class="greenbullet"></span>'
      text << link_to('Toggle state', mark_unavailable_instrument_path(instrument), :method => :put, :class => "toggle", :id => "unavailable_#{instrument.id}")
    else
      text << '<span class="redbullet"></span>'
      text << link_to('Toggle state', mark_available_instrument_path(instrument), :method => :put, :class => "toggle", :id => "available_#{instrument.id}")
    end
    text.html_safe
  end

  def render_rule(instrument, name)
    list = "#{name}_file_type_names"
    return if instrument.instrument_rule.blank?
    instrument.instrument_rule.send(list).join('<br />').html_safe
  end

  def instrument_file_type_id(name)
    InstrumentFileType.find_by_name(name).id
  end
end
