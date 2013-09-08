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

  it 'should have the "File Location" as the sample_id' do
    slide_data = {"ACData ID" => 119, "File Location" => 'file\BOURNE HMU12-646-013345-1.L.1.svs'}
    aperio.generate_sample_id(slide_data).should eq 'BOURNE HMU12-646'
  end

end