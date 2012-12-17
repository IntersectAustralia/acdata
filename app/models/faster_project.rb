class FasterProject < ActiveRecord::Base
  @@cc = nil
  @@ch = nil

  def self.columns
    return @@cc if @@cc
    @@cc = Project.columns
  end

  def self.columns_hash
    return @@ch if @@ch
    @@ch = Project.columns_hash
  end

  def inspect
    Object.instance_method(:inspect).bind(self).call
  end

  %w(p_id p_name e_id e_name s_id s_name d_id d_name).each do |m|
    send :define_method, m.to_sym do
      read_attribute_before_type_cast(m)
    end
  end
end
