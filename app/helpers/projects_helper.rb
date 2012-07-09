module ProjectsHelper

  def has_samples?(container)
    container.samples.present? or
      (container.is_a?(Project) and
        Project.search({:id_eq => container.id,
          :experiments_samples_id_is_present => true}
        ).all.present?)
  end

  def has_attachments?(container)
    # Projects and Experiments can both have samples under them
    container.class.search({
        :id_eq => container.id,
        :samples_datasets_attachments_id_is_present => true}
    ).all.present? or
    # Only Projects can have Experiments under them
    (container.is_a?(Project) and
      Project.search({
        :id_eq => container.id,
        :experiments_samples_datasets_attachments_id_is_present => true}
      ).all.present?)
  end

end
