require 'ostruct'
require 'rack'

module Rswag
  module Ui
    class Configuration
      attr_reader :template_locations
      attr_accessor :basic_auth_enabled
      attr_accessor :config_object
      attr_accessor :oauth_config_object
      attr_reader :assets_root

      def initialize
        @template_locations = [
          # preferred override location
          "#{Rack::Directory.new('').root}/swagger/index.erb",
          # backwards compatible override location
          "#{Rack::Directory.new('').root}/app/views/rswag/ui/home/index.html.erb",
          # default location
          File.expand_path('../index.erb', __FILE__)
        ]
        @assets_root = File.expand_path('../../../../node_modules/swagger-ui-dist', __FILE__)
        @config_object = ConfigObject.new
        @oauth_config_object = {}
        @basic_auth_enabled = false
      end

      def swagger_endpoint(url, name)
        Rswag::Ui.deprecator.warn('Rswag::Ui: WARNING: The method will be renamed to "openapi_endpoint" in v3.0')
        openapi_endpoint(url, name)
      end

      def openapi_endpoint(url, name, condition = nil)
        @config_object[:urls] ||= []
        @config_object[:urls] << { url: url, name: name, condition: condition }
      end

      def basic_auth_credentials(username, password)
        @config_object[:basic_auth] = { username: username, password: password }
      end
      # rubocop:disable Naming/AccessorMethodName
      def get_binding
        binding
      end
      # rubocop:enable Naming/AccessorMethodName
    end

    class ConfigObject < Hash

      def to_json
        json = self.as_json
        # Override the urls values too apply condition
        json['urls'] = self[:urls].select do |endpoint|
          endpoint[:condition].nil? || endpoint[:condition].call(Thread.current[:current_user])
        end
        json.to_json
      end

    end
  end
end
