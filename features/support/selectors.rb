module HtmlSelectorsHelpers
  # Maps a name to a selector. Used primarily by the
  #
  #   When /^(.+) within (.+)$/ do |step, scope|
  #
  # step definitions in web_steps.rb
  #
  def selector_for(locator)
    case locator
      # special case for our checks on 'view detail' screens that use the div id
      # to find the label/value pairs
      when /div#display_(.+)/
        "div#display_#{$1}"

      when "the page"
        "html > body"

      when "autocomplete options"
        ".ui-autocomplete"

      when "project list"
        "#project_nav > #project_list"

      when "People with Access"
        "#members_table"

      when "close dataset wizard"
        "#close_dataset_dialog"

      when "next button"
        "div > #next_button"

      when "Back"
        "#back_button"

      when "Dataset name"
        "wizard"

      when /"Show Files" tab/
        'a[text()="Show Files"]/@href'

      when "Show Files"
        "#tabs-files"

      when "Extended Metadata"
        "#tabs-metadata"

      when "Extended Metadata table"
        "#tabs-metadata > table#extended_metadata tr"

      when /"Extended Metadata" tab/
        'a[text()="Extended Metadata"]/@href'

      when "Extracted Metadata table"
        "div#metadata_display > table#extracted_metadata tr"

      when "Metadata file types"
        "#instrument_rule_metadata"

      when "Export to Blog"
        "#eln_export_blog_name"

      when "Edit button"
        "a[id^=show_edit]"

      when "Project description"
        "#project_description"

      when "Class Name"
        "#memre_export_material_class_name"

      when "Form Description"
        "#memre_export_form_description"

      when "Technique"
        "#measurement_technique"

      when "Share"
        "#share_dropdown"

      when "Add"
        "#add_dropdown"

      when "Sample name"
        "#dataset_sample_id"

      # Add more mappings here.
      # Here is an example that pulls values out of the Regexp:
      #
      #  when /^the (notice|error|info) flash$/
      #    ".flash.#{$1}"

      # You can also return an array to use a different selector
      # type, like:
      #
      #  when /the header/
      #    [:xpath, "//header"]

      # This allows you to provide a quoted selector as the scope
      # for "within" steps as was previously the default for the
      # web steps:
      when /^"(.+)"$/
        $1

      else
        raise "Can't find mapping from \"#{locator}\" to a selector.\n" +
                  "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelpers)
