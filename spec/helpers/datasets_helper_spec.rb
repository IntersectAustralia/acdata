require 'spec_helper'

describe DatasetsHelper do

  it "should format the date" do
    date = Time.now()
    expected = date.strftime("%d/%m/%Y %H:%M:%S")
    helper.local_date(date).should == expected
  end

  describe "dataset paths" do
    before :each do
      instrument = Factory(:instrument)
      @project = Project.create(:name => 'project')
      @project_sample = @project.samples.create(:name => 'project sample')
      @project_experiment = @project.experiments.create(:name => 'project exp')
      @project_exp_sample = @project_experiment.samples.create(:name => 'project exp sample')
      @p_e_s_dataset = @project_exp_sample.datasets.create(:name => 'project exp sample dataset', :instrument => instrument)
      @p_s_dataset = @project_sample.datasets.create(:name => 'project sample dataset', :instrument => instrument)
      @expected_p_e_s = "/projects/#{@project.id}/experiments/#{@project_experiment.id}/samples/#{@project_exp_sample.id}"
      @expected_p_s = "/projects/#{@project.id}/samples/#{@project_sample.id}"
      @expected_p_e_s_d = @expected_p_e_s + "/datasets/#{@p_e_s_dataset.id}"
      @expected_p_s_d = @expected_p_s + "/datasets/#{@p_s_dataset.id}"
    end

    it "should get dataset path" do
      get_dataset_path(@p_e_s_dataset).should == @expected_p_e_s_d
      get_dataset_path(@p_s_dataset).should == @expected_p_s_d
    end

    it "should get upload dataset path" do
      get_upload_dataset_path(@p_e_s_dataset).should == @expected_p_e_s_d + '/upload'
      get_upload_dataset_path(@p_s_dataset).should == @expected_p_s_d + '/upload'
    end

    it "should get edit dataset path" do
      get_edit_dataset_path(@p_e_s_dataset).should == @expected_p_e_s_d + '/edit'
      get_edit_dataset_path(@p_s_dataset).should == @expected_p_s_d + '/edit'
    end

    it "should get new dataset path" do
      get_new_dataset_path(@project_exp_sample).should == @expected_p_e_s + '/datasets/new'
      get_new_dataset_path(@project_sample).should == @expected_p_s + '/datasets/new'
    end

    it "should get metadata dataset path" do
      get_metadata_dataset_path(@p_e_s_dataset).should == @expected_p_e_s_d + '/metadata'
      get_metadata_dataset_path(@p_s_dataset).should == @expected_p_s_d + '/metadata'
    end

    it "should get new eln export path" do
      get_eln_export_path(@p_e_s_dataset).should == "/datasets/#{@p_e_s_dataset.id}/eln_exports/new"
      get_eln_export_path(@p_s_dataset).should == "/datasets/#{@p_s_dataset.id}/eln_exports/new"
    end

    it "should get edit eln export path" do
      user = Factory(:user)
      ability = mock(Ability).as_null_object
      Ability.stub(:new).with(user) { ability }
      helper.stub(:current_user) { user }

      eln_export1 = @p_e_s_dataset.eln_exports.create!(:title => 'test', :blog_name => 'test', :section => 'test', :user => user)
      helper.get_eln_export_path(@p_e_s_dataset).should == "/datasets/#{@p_e_s_dataset.id}/eln_exports/#{eln_export1.id}/edit"

      eln_export2 = @p_s_dataset.eln_exports.create!(:title => 'test', :blog_name => 'test', :section => 'test', :user => user)
      helper.get_eln_export_path(@p_s_dataset).should == "/datasets/#{@p_s_dataset.id}/eln_exports/#{eln_export2.id}/edit"
    end

    it "should get memre export path" do
      get_memre_export_path(@p_e_s_dataset).should == "/datasets/#{@p_e_s_dataset.id}/memre_export/new"
      get_memre_export_path(@p_s_dataset).should == "/datasets/#{@p_s_dataset.id}/memre_export/new"

      memre_props = {
        :material_name => 'Test Material',
        :material_class_name => 'Organic',
        :form_description => 'Other'
      }
      memre_export1 = @p_e_s_dataset.create_memre_export(memre_props)
      memre_export1.save!
      memre_export2 = @p_s_dataset.create_memre_export(memre_props)
      memre_export2.save!
      get_memre_export_path(@p_e_s_dataset).should == "/datasets/#{@p_e_s_dataset.id}/memre_export/#{memre_export1.id}/edit"
      get_memre_export_path(@p_s_dataset).should == "/datasets/#{@p_s_dataset.id}/memre_export/#{memre_export2.id}/edit"
    end
  end

  describe "metadata files" do
    let(:ft1) { Factory(:instrument_file_type, :name => 'a') }
    let(:ft2) { Factory(:instrument_file_type, :name => 'b') }
    let(:instrument_rule) { Factory(:instrument_rule, :metadata_list => 'a,b') }
    let(:instrument) {
      Factory(:instrument, :instrument_file_types => [ft1, ft2], :instrument_rule => instrument_rule)
    }

    it "should return metadata file options string" do
      @dataset = Factory(:dataset, :instrument => instrument)
      metadata_file_options.should == 'a/b'
    end

    it "should return metadata file types" do
      @dataset = Factory(:dataset, :instrument => instrument)
      metadata_file_types.should == [ft1, ft2]
    end
  end

  it "should return a json mapping of available instruments by class" do
    i1 = Factory(:instrument, :is_available => true, :name => 'i1', :instrument_class => 'foo')
    i1.save!
    i2 = Factory(:instrument, :is_available => true, :name => 'i2', :instrument_class => 'foo')
    i2.save!
    get_instruments_json.should == "{\"foo\":{\"i1\":#{i1.id},\"i2\":#{i2.id}}}"
  end

  describe "thumbnails" do
    #show_thumbnail(attachment)
    #helper.stub(:thumbnail_img).should_receive...
    it "should have a thumbnail for previewable file types" do
      pending
    end
    it "should have a thumbnail for instrument file types that are folders" do
      pending
    end
    it "should have a thumbnail for generic folders" do
      pending
    end
    it "should have a thumbnail for supported file types" do
      pending
    end
    it "should have a default thumbnail for unknown file types" do
      pending
    end
  end

  describe "showing filenames" do
    it "should show previewable attachments with filename and preview" do
      attachment = Factory(:attachment, :filename => 'foo.jpg', :preview_file => '.foo.jpg', :preview_mime_type => 'image/jpeg')
      result = show_filename(attachment)
      result.should match Regexp.quote(preview_attachment_path(attachment))
      result.should match Regexp.quote(attachment.filename)
    end

    it "should show the filename of an attachment" do
      attachment = Factory(:attachment, :filename => 'foo')
      show_filename(attachment).should == attachment.filename
    end
  end

  describe "known file types" do
    before :each do
      @old_config = APP_CONFIG['known_formats']
      APP_CONFIG['known_formats'] = %w{a b c}
    end

    after :each do
      APP_CONFIG['known_formats'] = @old_config
    end

    it "should return true for known file types" do
      att = Factory(:attachment, :filename => 'file.a')
      known_file_type?(att).should be_true
    end

    it "should return false for unknown file types" do
      att = Factory(:attachment, :filename => 'file.d')
      known_file_type?(att).should be_false
    end

    it "should return false for files without file extensions" do
      att = Factory(:attachment, :filename => 'file')
      known_file_type?(att).should be_false
    end
  end

  describe "upload prompt" do
    it "should return the instrument's prompt message if present" do
      prompt = 'upload a test file'
      instrument = Factory(:instrument, :upload_prompt => prompt)
      helper.upload_prompt(instrument).should == prompt
    end

    it "should return a default prompt if no instrument prompt is present" do
      instrument = Factory(:instrument)
      helper.upload_prompt(instrument).should == "Select files or folders to upload"
    end
  end

  describe "update prompt" do
    it "should give a prompt for a folder if the original is a folder" do
      attachment = Factory(:attachment, :format => 'folder')
      update_prompt(attachment).should =~ /\bfolder\b/
    end

    it "should give a prompt for a generic file if their is no file extension" do
      attachment = Factory(:attachment, :filename => 'foo')
      update_prompt(attachment).should =~ /\bfile\b/
    end

    it "should give a prompt containing a file extension if the original had one" do
      attachment = Factory(:attachment, :filename => 'foo.bar')
      update_prompt(attachment).should =~ /\bbar\b/
    end
  end

  it "should return a download path for an attachment" do
    attachment = Factory(:attachment, :filename => 'bar')
    attachment_download_link(attachment).should =~ /"#{download_attachment_path(attachment)}"/
  end

  describe "visualisation attachment" do
    it "should return the filename of the visualisation attachment" do
      pending
      #visualisation_tab_title
    end

    it "should " do
      pending
      #visualisation_partial
    end

    it "should " do
      pending
      #visualisation_file_options
    end

    it "should " do
      pending
      #visualisation_types
    end

    it "should " do
      pending
      #can_visualise?(instrument)
    end

  end

  it "should " do
    pending
    #non_empty_projects(projects)
  end

  it "should " do
    pending
    #get_samples_json(projects)
  end

  it "should " do
    pending
    #get_samples(samples)
  end

end
