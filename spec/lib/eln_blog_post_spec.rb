require 'spec_helper'

describe "ELNBlogPost" do

  before :all do
    @timestamp = Time.now
  end

  before :each do
    Settings.instance.update_attribute(:file_size_limit, 64)
  end

  after :all do
    @timestamp = nil
  end

  let(:uid){ 123 }

  let(:base_url) { 'http://example.com' }

  let(:title) { 'Test Title' }

  let(:title_with_bad_chars) { 'Test Title & <other>' }

  let(:metadata) {
    {
      "testkey" => "testvalue"
    }
  }

  let(:post_success){<<EOM
<?xml version="1.0" encoding="UTF-8"?>
<result><success>true</success><status_code>200</status_code><post_id>9164</post_id><post_info>#{base_url}/acdata_test/9164/test_title.xml</post_info></result>
EOM
  }

  let(:add_files_success){<<EOM
<?xml version="1.0" encoding="UTF-8"?>
<result><success>true</success><status_code>200</status_code><data_id>6464</data_id></result>
EOM
  }

  let(:expected_post_url){"#{base_url}/acdata_test/9164/test_title"}


  let(:expected_create_body){<<EOM
<?xml version="1.0" encoding="UTF-8"?>
<post>
    <title>#{title}</title>
    <section>Results</section>
    <author>
        <username>z1</username>
    </author>
    <content><![CDATA[This is a test post]]></content>
    <datestamp>#{@timestamp.iso8601}</datestamp>
    <blog_sname>acdata_test</blog_sname>
    <metadata>
        <testkey>testvalue</testkey>
    </metadata>
    <attached_data/>
</post>
EOM
  }

  let(:expected_create_with_files_body){<<EOM
<?xml version="1.0" encoding="UTF-8"?>
<post>
    <title>#{title}</title>
    <section>Results</section>
    <author>
        <username>z1</username>
    </author>
    <content><![CDATA[This is a test post]]></content>
    <datestamp>#{@timestamp.iso8601}</datestamp>
    <blog_sname>acdata_test</blog_sname>
    <metadata>
        <testkey>testvalue</testkey>
    </metadata>
    <attached_data>
        <data type="local">6464</data>
    </attached_data>
</post>
EOM
  }

  let(:expected_create_body_with_normalisation){<<EOM
<?xml version="1.0" encoding="UTF-8"?>
<post>
    <title>#{title}</title>
    <section>Results</section>
    <author>
        <username>z1</username>
    </author>
    <content><![CDATA[This is a test post]]></content>
    <datestamp>#{@timestamp.iso8601}</datestamp>
    <blog_sname>acdata_test</blog_sname>
    <metadata>
        <_testkey>testvalue</_testkey>
    </metadata>
    <attached_data/>
</post>
EOM
  }

  let(:expected_add_files_body){<<EOM
<?xml version="1.0" encoding="UTF-8"?>
<dataset>
    <title>test.txt</title>
    <data>
        <dataitem type="inline" main="1" ext="txt" filename="test.txt">VGVzdCBmaWxlCg==</dataitem>
    </data>
</dataset>
EOM
  }

  let(:expected_add_files_bad_title_body){<<EOM
<?xml version="1.0" encoding="UTF-8"?>
<dataset>
    <title>good and bad _test_.txt</title>
    <data>
        <dataitem type="inline" main="1" ext="txt" filename="good and bad _test_.txt">VGVzdCBmaWxlCg==</dataitem>
    </data>
</dataset>
EOM
  }

  let(:expected_add_directory_body){<<EOM
<?xml version="1.0" encoding="UTF-8"?>
<dataset>
    <title>test_dir.zip</title>
    <data>
        <dataitem type="inline" main="1" ext="zip" filename="test_dir.zip">UEsDBAoAAAAAANFcVkAOkxuRCgAAAAoAAAAIABUAdGVzdC50eHRVVAkAAwk5RE+yMKJPVXgEAPQB9AFUZXN0IGZpbGUKUEsBAhcDCgAAAAAA0VxWQA6TG5EKAAAACgAAAAgADQAAAAAAAQAAALSBAAAAAHRlc3QudHh0VVQFAAMJOURPVXgAAFBLBQYAAAAAAQABAEMAAABFAAAAAAA=</dataitem>
    </data>
</dataset>
EOM
  }

  let(:expected_update_body){<<EOM
<?xml version="1.0" encoding="UTF-8"?>
<post>
    <id>9164</id>
    <title>#{title}</title>
    <section>Results</section>
    <author>
        <username>z1</username>
    </author>
    <content><![CDATA[This is a test post with an update]]></content>
    <datestamp>#{@timestamp.iso8601}</datestamp>
    <blog_sname>acdata_test</blog_sname>
    <metadata>
        <testkey>testvalue</testkey>
    </metadata>
    <attached_data/>
    <edit_reason>testing updating</edit_reason>
</post>
EOM
  }

  it "should create a new blog post" do
    stub_request(:post, "#{base_url}/api/rest/addpost/uid/#{uid}")
      .with(:body => {"request" => expected_create_body})
      .to_return(:body => post_success, :status => ['200', 'OK'])
    create_post(title, metadata, 'This is a test post')

  end

  it "should create a new blog post, normalising as needed" do
    stub_request(:post, "#{base_url}/api/rest/addpost/uid/#{uid}")
      .with(:body => {"request" => expected_create_body_with_normalisation})
      .to_return(:body => post_success, :status => ['200', 'OK'])
    bad_metadata = { '$testkey' => 'testvalue' }
    create_post(title, bad_metadata, 'This is a test post')
  end

  it "should add files" do
    stub_request(:post, "#{base_url}/api/rest/adddata/uid/#{uid}")
      .with(:body => {"request" => expected_add_files_body})
      .to_return(:body => add_files_success, :status => ['200', 'OK'])
    add_files
  end

  it "should add directories as a zip file" do
    stub_request(:post, "#{base_url}/api/rest/adddata/uid/#{uid}")
      .with(:body => {"request"=> expected_add_directory_body})
      .to_return(:status => ['200', 'OK'], :body => add_files_success)

    d1 = Factory(:dataset)
    att = Attachment.create!(:dataset => d1, :format => 'folder', :filename => 'test_dir')
    FileUtils.mkdir_p(d1.dataset_path)
    poster = ELNBlogPost.new(base_url, uid)
    poster.stub(:generate_zip).and_return('spec/resources/test.zip')
    att.stub(:file_size).and_return(1)
    file_ids, file_links = poster.add_files([att])
  end



  it "should update a blog post" do
    stub_request(:post, "#{base_url}/api/rest/editpost/uid/#{uid}")
      .with(:body => {"request" => expected_update_body})
      .to_return(:body => post_success, :status => ['200', 'OK'])
    create_post(title, metadata, 'This is a test post with an update',[],[], expected_post_url)
  end

  it "should encode filenames" do
    stub_request(:post, "#{base_url}/api/rest/adddata/uid/#{uid}")
      .with(:body => {"request" => expected_add_files_bad_title_body})
      .to_return(:body => add_files_success, :status => ['200', 'OK'])
    poster = ELNBlogPost.new(base_url, uid)
    d1 = Factory(:dataset)
    att = Attachment.create!(:dataset => d1, :format => 'file', :filename => 'good & "bad" <test>.txt')
    file = File.open('spec/resources/test.txt')
    File.stub(:open).and_return(file)
    att.stub(:file_size).and_return(1)
    file_ids, file_links = poster.add_files([att])
  end

  it "should normalise" do
    ELNBlogPost.normalise('!@#$%^&*()').should == '__________'
    ELNBlogPost.normalise('2AB').should == '_ab'
    ELNBlogPost.normalise('ABc').should == 'abc'
  end

  it "should sanitise" do
    ELNBlogPost.sanitise('&').should == 'and'
    ELNBlogPost.sanitise('<>', true).should == '__'
    ELNBlogPost.sanitise('<>').should == '<>'
  end

  it "should clean filenames" do
    ELNBlogPost.clean_filename('"foo"').should == 'foo'
  end

  it "should add files to a blog post and link anything that roughly exceeds 64MB after encoding (ie 46MB and above)" do
    stub_request(:post, "#{base_url}/api/rest/adddata/uid/#{uid}")
      .with(:body => {"request" => expected_add_files_body})
      .to_return(:body => add_files_success, :status => ['200', 'OK'])

    file_ids, file_links = add_files

    expected_create_with_oversized_file_body = <<EOM
<?xml version="1.0" encoding="UTF-8"?>
<post>
    <title>#{title}</title>
    <section>Results</section>
    <author>
        <username>z1</username>
    </author>
    <content><![CDATA[This is a test post\nDownload test2.txt (larger than 64MB) at http://localhost:3000/attachments/#{Attachment.last.id}/download]]></content>
    <datestamp>#{@timestamp.iso8601}</datestamp>
    <blog_sname>acdata_test</blog_sname>
    <metadata>
        <testkey>testvalue</testkey>
    </metadata>
    <attached_data>
        <data type="local">6464</data>
    </attached_data>
</post>
EOM

    stub_request(:post, "#{base_url}/api/rest/addpost/uid/#{uid}")
      .with(:body => {"request" => expected_create_with_oversized_file_body})
      .to_return(:body => post_success, :status => ['200', 'OK'])

    create_post(title, metadata, 'This is a test post', file_ids, file_links)
  end

  def create_post(title, metadata, content, file_ids=[], file_links = [], existing_post_url=nil)
    poster = ELNBlogPost.new(base_url, uid)
    user_login = 'z1'
    blog_name = 'acdata_test'
    section = 'Results'
    reason = 'testing updating'
    post_url = poster.post(
      user_login,
      blog_name,
      title,
      section,
      content,
      @timestamp,
      metadata,
      file_ids,
      file_links,
      existing_post_url,
      (existing_post_url.nil? ? nil : reason)
    )
    post_url.should == expected_post_url
  end

  def create_attachment(dataset, filename, type='file')
    Attachment.create!(:dataset => dataset, :format => type, :filename => filename)
  end

  def add_files
    poster = ELNBlogPost.new(base_url, uid)
    file1 = File.open('spec/resources/test.txt')
    file2 = File.open('spec/resources/test2.txt')
    d1 = Factory(:dataset)

    File.stub(:open).and_return(file1, file2)

    files = [create_attachment(d1, 'test.txt'), create_attachment(d1, 'test2.txt')]
    files[0].stub(:file_size).and_return(1)
    files[1].stub(:file_size).and_return(46.megabytes)
    file_ids, file_links = poster.add_files(files)
    return file_ids, file_links
  end

end
