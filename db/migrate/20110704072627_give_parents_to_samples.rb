class GiveParentsToSamples < ActiveRecord::Migration
  def self.up

    say "Adding polymorphic key 'samplable' to Sample model"
    change_table :samples do |t|
      t.references :samplable, :polymorphic => true
    end

    say "Giving each sample a polymorphic association"

    Sample.find_each do |s|
      if s.experiment_id.present?
        s.samplable_id = s.experiment_id
        s.samplable_type = "Experiment"

      end

      if s.project_id.present?
        s.samplable_id = s.project_id
        s.samplable_type = "Project"
      end

      if s.samplable_type.present?
        say "#{s.id}:#{s.name} -> #{s.samplable_type}[#{s.samplable_id}]", true
      else
        say "#{s.id}:#{s.name} -> No parent found!!"
      end
      
      s.save

    end

    say "Removing old cols"
    change_table :samples do |t|
      t.remove(:experiment_id)
      t.remove(:project_id)
    end

  end

  def self.down


    say "Adding old keys to Sample model"
    change_table :samples do |t|
      t.integer  "project_id"
      t.integer  "experiment_id"
    end

    say "reverting polymorphic associations"

    Sample.find_each do |s|
      if s.samplable_type.eql?("Experiment")
        s.experiment_id = s.samplable_id
      end

      if s.samplable_type.eql?("Project")
        s.project_id = s.samplable_id
      end

      if  (s.project_id.blank? && s.experiment_id.blank?)
        say "#{s.id}:#{s.name} -> No parent found!!"
      else
        say "#{s.id}:#{s.name} -> #{s.samplable_type}[#{s.samplable_id}]", true
      end

      s.save

    end

    say "Removing old cols"
    change_table :samples do |t|
      t.remove(:samplable_id)
      t.remove(:samplable_type)
    end

  end
end
