class PasswordFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)  
    unless value =~ /^.*(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#%;:'"$^&*()_+={}|<>?,.~`\-\[\]\/\\]).*$/
      object.errors[attribute] << (options[:message] || "must be at least 6 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol")  
    end  
  end  
end