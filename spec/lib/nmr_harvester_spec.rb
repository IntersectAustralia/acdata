require 'spec_helper'
require 'rake' # Provides FileList

describe NMRHarvester do
  let(:ftp_sample_list) {
    [
        'drw-rw-rw-   1 user     group           0 Feb 14 23:54 .',
        'drw-rw-rw-   1 user     group           0 Feb 13 03:59 ..',
        "drw-rw-rw-   1 user     group           0 #{(Time.now - 5.days).strftime("%b %d %H:%M")} 120213-foo",
        "drw-rw-rw-   1 user     group           0 #{(Time.now - 10.days).strftime("%b %d %H:%M")} 120214-foo",
    ]
  }
  before :all do
    @i1 = Factory(:instrument, :id => 100, :instrument_class => 'NMR', :name => 'aaa (Flip)')
    @i2 = Factory(:instrument, :id => 101, :instrument_class => 'Not NMR', :name => 'bbb (bar)')
    @i3 = Factory(:instrument, :id => 102, :instrument_class => 'NMR', :name => 'ccc (Gyro)')
    FileUtils.cp_r FileList["spec/resources/nmr_backup/*"], "spec/resources/"

  end

  after :all do
    FileUtils.rm_rf("spec/resources/nmr")
  end

  after :all do
    Instrument.delete_all
  end

  it "should return users who have set their NMR username" do
    u1 = Factory(:user, :status => 'A', :nmr_username => 'aaa', :nmr_enabled => true)
    u2 = Factory(:user, :status => 'A')
    u3 = Factory(:user, :status => 'A', :nmr_username => 'BBB', :nmr_enabled => true)
    u4 = Factory(:user, :status => 'A', :nmr_username => 'CCC', :nmr_enabled => false)
    users = NMRHarvester.get_users
    users.to_a.should =~ [u1, u3]
  end

  it "should return a list of NMR instruments" do
    NMRHarvester.get_instruments.map { |i| NMRHarvester.get_instrument_name(i) }.should =~ %w{Flip Gyro}
  end

  it "should give the short name of the NMR instrument" do
    NMRHarvester.get_instrument_name(@i1).should == 'Flip'
  end

  it "should fetch NMR datasets of any age" do
    fetch_test
  end

  it "should fetch NMR datasets newer than a given date" do
    date_after = Time.now - 7.days
    fetch_test(date_after)
  end

  def fetch_test(date_after=nil)
    u1 = Factory(:user, :status => 'A', :nmr_username => 'foo', :nmr_enabled => true)
    ftp = stub('ftp')

    instruments = NMRHarvester.get_instruments
    users = NMRHarvester.get_users

    ftp.should_receive('nlst').and_return(%w{Flip Gyro})
    instruments.each do |instrument|
      ftp.should_receive('chdir').with("#{NMRHarvester.get_instrument_name(instrument)}/data")
      ftp.should_receive('nlst').and_return(%w{aaa foo})

      users.each do |user|
        ftp.should_receive('nlst').with("#{user.nmr_username}").and_return(%w{nmr})
        ftp.should_receive('chdir').with("#{user.nmr_username}/nmr")
        ftp.should_receive('list').and_return(ftp_sample_list)
        ftp.should_receive('get_dir').with("tmp/nmr/#{instrument.id}/#{u1.id}/120213-foo", '120213-foo')
        if date_after.nil?
          ftp.should_receive('get_dir').with("tmp/nmr/#{instrument.id}/#{u1.id}/120214-foo", '120214-foo')
        end
        ftp.should_receive('chdir').with('../..')
      end

      # end of this instrument
      ftp.should_receive('chdir').with('../..')
    end
    ftp.should_receive('close')
    NMRHarvester.fetch_datasets(ftp, instruments, users, 'tmp/nmr', date_after)
  end

end

