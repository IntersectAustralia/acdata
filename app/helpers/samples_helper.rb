module SamplesHelper

  def sample_path(sample)
    if sample.samplable.is_a?(Project)
      project_sample_path(sample.samplable, sample)
    else
      project_experiment_sample_path(sample.samplable.project, sample.samplable, sample)
    end
  end

  def edit_sample_path(sample)
    if sample.samplable.is_a?(Project)
      edit_project_sample_path(sample.samplable, sample)
    else
      edit_project_experiment_sample_path(sample.samplable.project, sample.samplable, sample)
    end
  end

  def get_project_experiments_json(projects)
    proj_exp = {}
    projects.each do |project|
      proj_exp[project.id] = {}
      project.experiments.map{|exp| proj_exp[project.id][exp.id] = exp.name }
    end
    proj_exp.to_json.html_safe
  end
end
