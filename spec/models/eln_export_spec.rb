require 'spec_helper'

describe ElnExport do
  before :each do
    dataset = Factory(:dataset)
    @eln_export = Factory(:eln_export, :dataset => dataset)
    @eln_export.eln_export_metadatas.create!(:key => 'foo', :value => 'bar')
  end

  it "should return the metadata as a hash" do
    @eln_export.metadata_as_hash.should == { 'foo' => 'bar' }
  end

  it "should destroy associated metadata when deleted" do
    other_dataset = Factory(:dataset)
    other_eln_export = Factory(:eln_export, :dataset => other_dataset)
    other_eln_export.eln_export_metadatas.create!(:key => 'baz', :value => 'quux')
    ElnExportMetadata.all.size.should == 2
    ElnExportMetadata.where(:eln_export => @eln_export).size.should == 1
    @eln_export.destroy
    ElnExportMetadata.where(:eln_export => @eln_export).size.should == 0
  end
end
