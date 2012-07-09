Devise::FailureApp.class_eval do
  def store_location!
    if request.get? && !http_auth?
      if request.xhr?
        session["#{scope}_return_to"] = request.referrer
        session["#{scope}_ajax_call"] = attempted_path
      else
        session["#{scope}_return_to"] = attempted_path

      end
    end

  end

end
