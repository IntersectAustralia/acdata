module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

      when /the home\s?page/
        '/'

      # User paths
      when /the login page/
        new_user_session_path

      when /the logout page/
        destroy_user_session_path

      when /the admin page/
        admin_users_path

      when /the edit handles page/
        edit_handles_settings_path

      when /the request account page/
        new_user_registration_path

      when /the user registration page/
        new_user_registration_path

      when /^the user details page for (.*)$/
        user_path(User.where(:login => $1).first)

      when /^the edit user details page$/
        edit_user_registration_path

      when /^the edit role page for (.*)$/
        edit_role_user_path(User.where(:login => $1).first)

      when /the access requests page/
        access_requests_users_path

      when /the list users page/
        users_path

      when /my projects page/
        projects_path

      when /the project page for "(.*)"$/
        project = Project.find_by_name($1)
        project_path(project)

      when /the edit project page for "(.*)"$/
        edit_project_path(Project.find_by_name($1))

      when /the experiment page for "(.+)"$/
        experiment = Experiment.where(:name => $1).first
        project_experiment_path(experiment.project, experiment)

      when /the edit experiment page for "(.*)"$/
        experiment = Experiment.find_by_name($1)
        edit_project_experiment_path(experiment.project, experiment)

      when /the new dataset page for "(.*)"$/
        sample = Sample.find_by_name($1)
        if sample.samplable.is_a?(Project)
          new_project_sample_dataset_path(sample.samplable, sample)
        elsif sample.samplable.is_a?(Experiment)
          new_project_experiment_sample_dataset_path(sample.samplable.project, sample.samplable, sample)
        end

      when /the sample page for "(.*)"$/
        sample = Sample.find_by_name($1)
        if sample.samplable.is_a?(Project)
          project_sample_path(sample.samplable, sample)
        elsif sample.samplable.is_a?(Experiment)
          project_experiment_sample_path(sample.samplable.project, sample.samplable, sample)
        end

      when /the upload page for "(.*)"$/
        sample = Sample.find_by_name($1)
        if sample.samplable.is_a?(Project)
          project_sample_datasets_path(sample.samplable, sample)
        elsif sample.samplable.is_a?(Experiment)
          project_experiment_sample_datasets_path(sample.samplable.project, sample.samplable, sample)
        end

      when /the view dataset page for "(.*)" under sample "(.*)" under project "(.*)"$/
        dataset = Dataset.find_by_name($1)
        sample = Sample.find_by_name($2)
        project = Project.find_by_name($3)
        project_sample_dataset_path(project, sample, dataset)

      when /the view dataset page for "(.*)"$/
        dataset = Dataset.find_by_name($1)
        sample = dataset.sample
        if sample.samplable.is_a?(Experiment)
          experiment = sample.samplable
          project = experiment.project
          project_experiment_sample_dataset_path(project, experiment, sample, dataset)
        else
          project = sample.samplable
          project_sample_dataset_path(project, sample, dataset)
        end

      when /the metadata page for dataset "(.*)"$/
        dataset = Dataset.find_by_name($1)
        sample = dataset.sample
        if sample.samplable.is_a?(Experiment)
          experiment = sample.samplable
          project = experiment.project
          project_experiment_sample_dataset_path(project, experiment, sample, dataset, :anchor => '#tabs-metadata')
        else
          project = sample.samplable
          project_sample_dataset_path(project, sample, dataset, :anchor => '#tabs-metadata')
        end

      when /the download page for dataset "(.*)"$/
        dataset = Dataset.find_by_name($1)
        download_dataset_path(dataset)

      when /the create new instrument page$/
        new_instrument_path

      when /the instrument management page$/
        instruments_path

      when /the instrument view page for "(.*)"$/
        instrument = Instrument.find_by_name($1)
        instrument_path(instrument)

# Add more mappings here.
      # Here is an example that pulls values out of the Regexp:
      #
      #   when /^(.*)'s profile page$/i
      #     user_profile_path(User.find_by_login($1))

      else
        begin
          page_name =~ /the (.*) page/
          path_components = $1.split(/\s+/)
          self.send(path_components.push('path').join('_').to_sym)
        rescue Object => e
          raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
                    "Now, go and add a mapping in #{__FILE__}"
        end
    end
  end
end

World(NavigationHelpers)
