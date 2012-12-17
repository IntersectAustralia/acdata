module FasterLinkHelper

  def faster_link_to_project(id, name, title, type, empty, current)
    buf = '<a href="/projects/'
    buf << id << '#project_' << id << '" class="' << type << empty << current << '" id="project_' << id << '" title="' << title << '">' << name << '</a>'
  end

  def faster_link_to_experiment(p_id, e_id, e_name, e_title, e_current)
    buf = '<a href="/projects/'
    buf << p_id << '/experiments/' << e_id << '#experiment_' << e_id << '" class="project_experiment' << e_current << '" id="experiment_' << e_id << '" title="' << e_title << '">' << e_name << '</a>'
  end

  def faster_link_to_project_sample(p_id, s_id, s_name, s_title, s_current)
    buf = '<a href="/projects/'
    buf << p_id << '/samples/' << s_id << '#experiment_sample_' << s_id << '" class="experiment_sample' << s_current << '" id="experiment_sample_' << s_id << '" title="' << s_title << '">' << s_name << '</a>'
  end

  def faster_link_to_project_experiment_sample(p_id, e_id, s_id, s_name, s_title, s_current)
    buf = '<a href="/projects/'
    buf << p_id << '/experiments/' << e_id << '/samples/' << s_id << '#experiment_sample_' << s_id << '" class="experiment_sample' << s_current << '" id="experiment_sample_' << s_id << '" title="' << s_title << '">' << s_name << '</a>'
  end

  def faster_link_to_project_sample_dataset(p_id, s_id, d_id, d_name, d_title, d_current)
    buf = '<a href="/projects/'
    buf << p_id << '/samples/' << s_id << '/datasets/' << d_id << '#experiment_sample_' << s_id << '" class="experiment_sample_dataset' << d_current << '" title="' << d_title << '">' << d_name << '</a>'
  end

  def faster_link_to_project_experiment_sample_dataset(p_id, e_id, s_id, d_id, d_name, d_title, d_current)
    buf = '<a href="/projects/'
    buf << p_id << '/experiments/' << e_id << '/samples/' << s_id << '/datasets/' << d_id << '#experiment_sample_' << s_id << '" class="experiment_sample_dataset' << d_current << '" title="' << d_title << '">' << d_name << '</a>'
  end

end