module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

  def form_header(title)
    "<div class=\"contentbox_header\"><strong>#{h title}</strong></div>".html_safe
  end

  # convenience method to render a field on a view screen - saves repeating the div/span etc each time
  def render_field(label, value)
    render_field_content(label, (h value))
  end

  def render_field_if_not_empty(label, value)
    render_field_content(label, (h value)) if value != nil && !value.empty?
  end

  def icon(type)
    "<img src='/images/icon_#{type}.png' border=0 class='icon' alt='#{type}' />".html_safe
  end

  # as above but takes a block for the field value
  def render_field_with_block(label, &block)
    content = with_output_buffer(&block)
    render_field_content(label, (h content))
  end

  def render_safe_html(text)
    return if text.nil?
    sanitize(newline_to_br(text)).html_safe
  end

  def newline_to_br(text)
    return text unless text and text.match(/\r|\n/)
    display_text = text
    display_text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
    display_text.gsub!(/\n/, '<br />')
    display_text
  end

  def is_current_project?(project)
    if request.fullpath.starts_with?("/projects")
      id = params[:controller].eql?("projects") ? params[:id] : params[:project_id]
      if project[:node_data].p_id == id
        return true
      end
    end
    return false
  end

  def is_current_sample?(sample)
    if request.fullpath.starts_with?("/projects")
      id = params[:controller].eql?("samples") ? params[:id] : params[:sample_id]
      if sample[:node_data].s_id == id
        return true
      end
    end
    return false
  end

  def is_current_experiment?(experiment)
    if request.fullpath.starts_with?("/projects")
      id = params[:controller].eql?("experiments") ? params[:id] : params[:experiment_id]
      if experiment[:node_data].e_id == id
        return true
      end
    end
    return false
  end

  def is_current_dataset?(dataset)
    if request.fullpath.starts_with?("/projects")
      id = params[:controller].eql?("datasets") ? params[:id] : params[:dataset_id]
      if dataset.d_id == id
        return true
      end
    end
    return false
  end

  def split_list(list)
    half = (list.size / 2.to_f).ceil
    [list[0, half], list[half, list.size]]
  end

  private
  def render_field_content(label, content)
    div_class = cycle("field_bg","field_nobg")
    div_id = label.tr(" ,", "_").downcase
    html = "<div class='#{div_class} inlineblock' id='display_#{div_id}'>"
    html << '<span class="label_view">'
    html << (h label)
    html << ":"
    html << '</span>'
    html << '<span class="field_value">'
    html << content
    html << '</span>'
    html << '</div>'
    html.html_safe
  end


end
