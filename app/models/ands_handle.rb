class AndsHandle < ActiveRecord::Base
  belongs_to :assignable, :polymorphic => true

  validates_uniqueness_of :key, :case_sensitive => false
  validates_uniqueness_of :assignable_id, :scope => :assignable_type
  validates_format_of :key, :with => /^hdl:1959.4\/004_\d+$/i, :on => :create

  validates_presence_of :key
  validates_presence_of :assignable_id
  validates_inclusion_of :assignable_type, :in => %w( Instrument AndsPublishable Activity ), :message => "Type '%s' neither 'Instrument','Activity' or 'AndsPublishable'"

  before_validation :strip_whitespace


  def strip_whitespace
    key.strip! if key
  end

  def handle_within_range

    if settings.end_handle_range.present?
      start_num = Settings.instance.start_handle_range[/\d+$/].to_i
      end_num = Settings.instance.end_handle_range[/\d+$/].to_i

      handles = (start_num..end_num).to_a.collect { |x| "hdl:1959.4/004_#{x}" }
      free_handles = handles - AndsHandle.select(:key).collect(&:key)

    end

  end

  def self.assign_handle(assignable)

    if assignable.handle
      Rails.logger.debug("#{assignable.class}:#{assignable.id} already has a handle")
      return assignable.handle
    end

    settings = Settings.instance

    if settings.end_handle_range.present?
      start_num = Settings.instance.start_handle_range[/\d+$/].to_i
      end_num = Settings.instance.end_handle_range[/\d+$/].to_i

      handles = (start_num..end_num).to_a.collect { |x| "hdl:1959.4/004_#{x}" }
      free_handles = handles - AndsHandle.select(:key).collect(&:key)

      if free_handles[0]
        new_key = free_handles[0]
      else
        assignable.errors.add(:base, "Handles exhausted and cannot be assigned. Please contact an administrator.") if free_handles.empty?
        raise ActiveRecord::Rollback

      end
      new_key = free_handles[0]

    elsif settings.start_handle_range.present? and settings.end_handle_range.blank?

      start_num = Settings.instance.start_handle_range[/\d+$/].to_i
      last_key = AndsHandle.select(:key).collect(&:key).sort! { |t1, t2| t1[/\d+$/].to_i <=> t2[/\d+$/].to_i }.last

      if last_key
        last_num = last_key[/\d+$/].to_i
      else
        last_num = start_num
      end

      handles = (start_num..last_num).to_a.collect { |x| "hdl:1959.4/004_#{x}" }
      free_handles = handles - AndsHandle.select(:key).collect(&:key)

      if free_handles[0]
        new_key = free_handles[0]
      else
        new_key = "hdl:1959.4/004_#{last_num + 1}"
      end

    else
      assignable.errors.add(:base, "No handles can be assigned at the moment. Please contact an administrator.")
      raise ActiveRecord::Rollback

    end

    new_handle = AndsHandle.new(:key => new_key, :assignable => assignable)
    begin
      new_handle.save!
      assignable.ands_handle = new_handle
      Rails.logger.debug("New handle #{new_key} assigned to #{new_handle.assignable_type}:#{new_handle.assignable_id}")
      return new_handle
    rescue Exception => e
      assignable.errors.merge!(new_handle.errors)
      raise ActiveRecord::Rollback, e.message

    end


  end


end
