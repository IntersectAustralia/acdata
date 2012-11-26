module PathBuilder

  class Path

    # builds a path that looks like
    # "project_#{@project.id}/experiment_#{@experiment.id}/sample_#{@sample.id}/dataset_#{@dataset.id}"
    def self.file_path(obj)
      gather_components(obj)
    end

    # Mac style filename truncation.
    # Displays as many characters as it can, always having the extension and if possible the last word

    def self.filename_trunc(file, max_length)

       min_word_length = 8

       if file.length >= max_length
         ext =  File.extname(file)
         tail = file.match /[\s_\-\.].{0,#{[[max_length - ext.length, [min_word_length,max_length].min].min,0].max}}#{ext}$/
         tail = tail.present? ? tail.to_s.strip : ext
         puts   [max_length.to_i-tail.length,0].max
         head = file.match /^.{0,#{[(max_length - tail.length),0].max}}/

         head.to_s.strip << "..." << tail
       else
         file
       end
     end


    private

    # Recursively builds the path, working up the model
    def self.gather_components(obj)
      case obj
        when Project
          "project_#{obj.id}"
        when Experiment
          gather_components(obj.project) << "/experiment_#{obj.id}"
        when Sample
          gather_components(obj.samplable) << "/sample_#{obj.id}"
        when Dataset
          gather_components(obj.sample) << "/dataset_#{obj.id}"
      end
    end
  end
end
