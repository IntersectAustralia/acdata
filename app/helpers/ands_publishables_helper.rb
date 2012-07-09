module AndsPublishablesHelper

  def get_publishable_link(project)
    if project.ands_publishable.present?
      publishable = project.ands_publishable
      get_approved_link(publishable)
    else
      link_to '<span>Publish Data to RDA</span>'.html_safe, new_project_ands_publishable_path(@project), {:remote => true, :id => 'show_new_ands_publishable_wizard', :class => ''}
    end
  end


  def get_templates_json
    APP_CONFIG['access_rights_templates'].to_json.html_safe
  end

  private

  def get_approved_link(publishable)
    if publishable.approved? or publishable.rejected?
      link_to '<span>Update Data to RDA</span>'.html_safe, edit_project_ands_publishable_path(@project, @project.ands_publishable), {:remote => true, :id => 'show_edit_ands_publishable_wizard', :class => ''}
    elsif publishable.to_be_submitted?
      link_to '<span>Publish Data to RDA</span>'.html_safe, edit_project_ands_publishable_path(@project, @project.ands_publishable), {:remote => true, :id => 'show_edit_ands_publishable_wizard', :class => ''}
    else
      link_to '<span>Update Data to RDA</span>'.html_safe, "", {:disabled => 'true'}
    end
  end

end
