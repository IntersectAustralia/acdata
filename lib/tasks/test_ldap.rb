require 'yaml'
require 'net/ldap'

class TestLDAP

  def initialize(environment=nil,config=nil,debug=false)
    @debug = debug
    @environment = environment.nil? || environment.empty? ? 'development' : environment
    @config = config.nil? ? self.get_config : config
    @base = @config['base']
    @ldap = Net::LDAP.new(:host => @config['host'],
      :port => @config['port'],
      :auth => {
        :method => :simple,
        :username => @config['admin_user'],
        :password => @config['admin_password']
      }) or raise ldap_error
  end

  def populate_ldap(user_set='test_users')
    begin
      self.delete_all
      self.create_ldap_tree
      test_user_file = File.expand_path("../../../config/#{user_set}.yml", __FILE__)
      users = YAML::load_file(test_user_file)
      if users.include?(@environment)
        self.add_users(users[@environment]['users'])
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n")
    end
  end

  def delete_all
    self.delete_users(list_users)

    parts = @base.split(/,\s*/)
    while !parts.empty?
      break if parts[0].match(/^dc=/)
      dn = parts.join(',')
      puts "Deleting dn: #{dn}" if @debug
      @ldap.delete(:dn => dn)
      parts.shift
    end
  end

  def create_domain(dc_string)
    (dc_key, dc) = dc_string.split(/\s*=\s*/)
    filter = Net::LDAP::Filter.eq('dc', dc)
    entries = @ldap.search(:base => dc_string, :filter => filter) || []

    if entries.empty?
      puts "Creating #{dc_string}" if @debug
      @ldap.add(:dn => dc_string, :attributes => make_ldap_attr(dc_string)) \
        or raise ldap_error
    end
  end

  def create_ldap_tree
    parts = @base.split(/,\s*/)

    dn = nil
    parts.reverse.each do |part|
      dn = dn.nil? ? part : "#{part},#{dn}"
      if part.match(/^dc=/)
        create_domain(part) 
        next
      end
      @ldap.add(:dn => dn, :attributes => make_ldap_attr(part)) \
        or raise ldap_error
      puts "Added dn: #{dn}" if @debug
    end
  end

  def add_users(users)
    users.each do |hash|
      dn = "cn=#{hash['login']},#{@base}"
      attr = {
        :cn => hash['login'],
        :objectclass => ["top", "inetorgperson"],
        :givenName => hash['first_name'],
        :sn => hash['last_name'],
        :mail => hash['email'],
        :userPassword => hash['password']
      }
      self.add_user(dn, attr)
      puts "Added #{dn}" if @debug
    end
  end

  def add_user(dn, attr)
    @ldap.add(:dn => dn, :attributes => attr) or raise ldap_error
  end

  def list_users
    filter = Net::LDAP::Filter.eq("cn", "*")

    entries = @ldap.search(:base => @base, :filter => filter) || []
    entries.map {|e| e.dn}
  end

  def delete_users(dn_list)
    dn_list.each do |dn|
      puts "Deleting #{dn}" if @debug
      @ldap.delete(:dn => dn) or raise ldap_error
    end
  end

  protected

  def get_config
    ldap_config_file = File.expand_path('../../../config/ldap.yml', __FILE__)
    ldap_config = YAML::load_file(ldap_config_file)[@environment]
  end

  def make_ldap_attr(part)
      (k,v) = part.split(/\s*=\s*/)
      { k => v, :objectclass => get_objectclass(k)}
  end

  def get_objectclass(key)
    case key
      when 'dc' then 'domain'
      when 'o'  then 'organization'
      when 'ou' then 'organizationalunit'
    end
  end

  def ldap_error
    Exception.new @ldap.get_operation_result.message
  end

end
