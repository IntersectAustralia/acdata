require 'net-ldap'
require 'yaml'

module UNSW
  module IDM

    class LDAPException < Exception
    end

    class LDAPConnector

      def initialize(environment,config=nil)
        @environment = environment || 'development'
        @config = config.nil? ? self.get_config : config
        @base = @config['base']
      end

      def get_user_details(login,password=nil)
        if password.nil? or password.empty?
          return nil
        end
        connect_and_auth
        method = @config['bind_method'] || :simple
        result = false
        #begin
          result = @ldap.bind_as(:base => @base,
                          :method => method,
                          :filter => "(cn=#{login})",
                          :password => password)
        #rescue Net::LDAP::LdapError => ldap_error
          #raise UNSW::IDM::LDAPException, ldap_error.message, ldap_error.backtrace
        #end

        raise UNSW::IDM::LDAPException.new(message) if is_error

        if !result
          return nil
        elsif result.size > 1
          raise UNSW::IDM::LDAPException.new("LDAP search for #{login} returned multiple (#{result.size}) results")
        end

        user = result.first
        return {
          :first_name => user['givenname'].first,
          :last_name  => user['sn'].empty? ? nil : user['sn'].first,
          :email      => user['mail'].first
        }

      end

      protected

      def get_config
        ldap_config_file = File.expand_path('../../config/ldap.yml', __FILE__)
        ldap_config = YAML::load_file(ldap_config_file)[@environment]
      end

      def is_error
        @ldap.get_operation_result.code != 0
      end

      def message
        @ldap.get_operation_result.message
      end

      def connect_and_auth
        @ldap = Net::LDAP.new(:host => @config['host'],
          :port => @config['port']
        ) or raise UNSW::IDM::LDAPException.new(message)
        @ldap.auth @config['admin_user'], @config['admin_password']
      end


    end

  end
end
