require File.dirname(__FILE__) + '/data_manager.rb'

begin  
  namespace :project_data do  
    desc "Save and restore user generated project data"

    task :save => :environment do
      save_data
    end

    task :restore => :environment do
      restore_data
    end

    task :delete => :environment do
      delete_data
    end
  end

  namespace :ands_handles do
    desc "Assign handles to instruments"

    task :assign_instruments => :environment do
      assign_instruments
    end

  end

  namespace :data do
    namespace :for_codes do
      desc "Populate Field of Research (FOR) Tags from CSV"

      task :load => :environment do
        import_for_codes
      end
    end

    namespace :seo_codes do
      desc "Populate SEO Tags from CSV"

      task :load => :environment do
        import_seo_codes
      end
    end

    namespace :fluorescent_labels do
      desc "Populate fluorescent labels from yml"

      task :load => :environment do
        import_fluorescent_labels
      end
    end

    namespace :slide_guidelines do
      desc "Populate slide guidelines from yml"

      task :load => :environment do
        import_slide_guidelines
      end
    end
  end
end
