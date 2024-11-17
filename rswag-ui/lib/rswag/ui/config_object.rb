module Rswag
  module Ui
    class ConfigObject < Hash

      def to_json
        json = self.as_json
        # Override the urls values too apply condition
        json['urls'] = self[:urls].select do |endpoint|
          endpoint.condition.nil? || endpoint.condition.call
        end
        json.to_json
      end

    end
  end
end
