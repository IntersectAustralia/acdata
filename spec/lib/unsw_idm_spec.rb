require 'spec_helper'
require File.expand_path('../../../lib/tasks/test_ldap.rb', __FILE__)
require File.expand_path('../../../lib//unsw_idm.rb', __FILE__)

describe "Authentication" do
  before :all do
    @ldap = TestLDAP.new('test')
    @ldap.populate_ldap
  end

  after :all do
    @ldap.delete_all
  end

  it "should get user details from the directory service" do
    idm_service = UNSW::IDM::LDAPConnector.new('test')
    res = idm_service.get_user_details('z1', 'Pass.123')
    res.should_not be_nil
    res[:first_name].should eql('Normal')
    res[:last_name].should eql('User1')
    res[:email].should eql('normal1@example.com.au')
  end
end
