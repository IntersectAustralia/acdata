require 'spec_helper'

describe Role do
  describe "Associations" do
    it { should have_many(:users) }
  end
  
  describe "Scopes" do
    describe "By name" do
      it "should order the roles by name and include all roles" do
        r1 = Role.create(:name => "bcd")
        r2 = Role.create(:name => "aaa")
        r3 = Role.create(:name => "abc")
        Role.by_name.should eq([r2, r3, r1])
      end
    end
  end
    
  describe "Validations" do
    it { should validate_presence_of(:name) }

    it "should reject duplicate names" do
      attr = {:name => "abc"}
      Role.create!(attr)
      with_duplicate_name = Role.new(attr)
      with_duplicate_name.should_not be_valid
    end

    it "should reject duplicate names identical except for case" do
      attr = {:name => "abc"}
      Role.create!(attr.merge(:name => "ABC"))
      with_duplicate_name = Role.new(@attr)
      with_duplicate_name.should_not be_valid
    end
  end

  describe "Get superuser emails" do
    it "should find all approved superusers and extract their email address" do
      super_role = Factory(:role, :name => "Superuser")
      admin_role = Factory(:role, :name => "Admin")
      super_1 = Factory(:user, :role => super_role, :status => "A", :email => "a@example.com.au")
      super_2 = Factory(:user, :role => super_role, :status => "U", :email => "b@example.com.au")
      super_3 = Factory(:user, :role => super_role, :status => "A", :email => "c@example.com.au")
      super_4 = Factory(:user, :role => super_role, :status => "D", :email => "d@example.com.au")
      super_5 = Factory(:user, :role => super_role, :status => "R", :email => "e@example.com.au")
      admin = Factory(:user, :role => admin_role, :status => "A", :email => "f@example.com.au")

      supers = Role.get_superuser_emails
      supers.size.should == 2
      supers.include?("a@example.com.au").should be_true
      supers.include?("c@example.com.au").should be_true
    end
  end

end
