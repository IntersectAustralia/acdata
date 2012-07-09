class ElnBlog < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :name
  validates_presence_of :user_id
  validates_length_of :name, :maximum => 255
  # probably shouldn't start/end with an underscore. this prevents nmr usernames with only underscores as well.
  validates_format_of :name, :with => /^\w[\w\_]+\w$/, :message => "must be alphanumeric with optional underscores"

  before_validation do
    name.strip! if name
  end
end
