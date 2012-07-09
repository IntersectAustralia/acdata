APP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/acdata_config.yml")[Rails.env]
sensitive_data = YAML.load_file("#{APP_CONFIG['deploy_config_root']}/acdata_deploy_config.yml")[Rails.env]

APP_CONFIG.merge!(sensitive_data)

MetaWhere.operator_overload!