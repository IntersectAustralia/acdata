require 'spec_helper'

describe AperioHarvester do

  let(:aperio) {
    config = {base_url: 'http://localhost:3000', project_list_url: 'http://localhost:3000/Records_List.php',
              export_data_url: 'http://localhost:3000/BulkExport.php?TableName=Project',
              slide_thumbnail_url: 'http://localhost:3000/imageserver/@__image_id__?0+0+500+500+-1+75+P+O',
              label_thumbnail_url: 'http://localhost:3000/imageserver/@__image_id__?0+0+500+500+-2+75+P+O',
              image_url: 'http://localhost:3000/imageserver/@__image_id__/view.apml',
              username: 'sq', password: 'password',
              instrument_name: 'SS6109',
              slide_file_type: 'Aperio Slide Thumbnail',
              label_file_type: 'Aperio Label Thumbnail',
              dataserver: {url: 'localhost', port: '3000'}}
    AperioHarvester.new config }

  let(:project) {
    double('project', :name => 'Aperio Test Project')
  }

  it 'should have the "User Specimen ID" as the sample_id if it is an Integer' do
    slide_data = {"ACData ID" => 119, "User Specimen ID" => '1234'}
    aperio.generate_sample_id(slide_data, project).should eq '1234'
  end

  it 'should have the "User Specimen ID" as the sample_id if it is a String' do
    slide_data = {"ACData ID" => 119, "User Specimen ID" => 'Some string'}
    aperio.generate_sample_id(slide_data, project).should eq 'Some string'
  end

  it 'should have the "<ProjectName>_sample(n)" as the sample_id if the "Specimen ID" is not supplied' do
    slide_data = {"ACData ID" => 119}
    aperio.generate_sample_id(slide_data, project).should eq 'AperioTestProject_sample1'
  end

  it 'should have the "<ProjectName>_sample(n+1)" as the sample_id if "<ProjectName>_sample(n)" already exists' do
    slide_data = {"ACData ID" => 119}
    sample = double('sample', :name => 'AperioTestProject_sample234')
    Sample.stub_chain(:where, :where, :order, :last) { sample }
    aperio.generate_sample_id(slide_data, project).should eq 'AperioTestProject_sample235'
  end

end