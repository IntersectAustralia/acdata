class Settings < ActiveRecord::Base
  acts_as_singleton
  validates_format_of :start_handle_range, :with => /^hdl:1959.4\/004_\d+$/i, :allow_blank => true
  validates_format_of :end_handle_range, :with => /^hdl:1959.4\/004_\d+$/i, :allow_blank => true
  validates :slide_scanning_email, :presence => true, :format => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/, :allow_blank => true, :length => {:maximum => 255}

  validate :valid_range

  has_many :slide_guidelines
  has_many :fluorescent_labels

  accepts_nested_attributes_for :slide_guidelines, :allow_destroy => true, :reject_if => proc { |attrs| attrs['description'].strip.blank?}
  accepts_nested_attributes_for :fluorescent_labels, :allow_destroy => true, :reject_if => proc { |attrs| attrs['name'].strip.blank?}

  def valid_range
    if end_handle_range.present? and start_handle_range.blank?
      errors.add(:base, "Start handle range must be defined if end handle range is specified")
    end

    if start_handle_range.present? and end_handle_range.present?
      if start_handle_range[/\d+$/].present? and end_handle_range[/\d+$/].present?
        start_num = start_handle_range[/\d+$/].to_i
        end_num = end_handle_range[/\d+$/].to_i

        errors.add(:base, "Start handle range must be less than end handle range") if start_num > end_num

      end
    end

    if start_handle_range.present? and end_handle_range.present?
      if start_handle_range[/\d+$/].present? and end_handle_range[/\d+$/].present?
        start_num = start_handle_range[/\d+$/].to_i
        end_num = end_handle_range[/\d+$/].to_i

        errors.add(:base, "Handles up to hdl:1959.4/004_299 are reserved for ResData projects.") if start_num < 300 or end_num < 300

      end
    end

  end

end
