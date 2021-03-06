require 'sneakers'
require 'sneakers_packer'
module SNT
  module Auth
    class RPC
      include ::SNT::Core::RPC

      # Execute remote procedural call on the auth application
      #
      # @param method [String] Name of method to call
      # @param message [Object] Argument list to send to remote method
      # @param options [Hash] Possible options include: timeout [Integer], namespace [String]
      # @return [Object] Response from remote service
      #
      def self.call(method, message, options = {})
        queue = options.delete(:queue) || 'api'

        SneakersPacker.remote_call(
          "auth.#{queue}.rpc",
          {
            request_id: SecureRandom.uuid,
            # Set expires_at based on SneakersPacker rpc_timeout in seconds of Epoch format per rfc1057
            expires_at: Time.now.to_f + (options[:timeout] || SneakersPacker.conf.rpc_timeout).to_f,
            created_at: Time.now.to_f,
            method: method,
            args: message
          }.tap { |o| o[:namespace] = options[:namespace] if options.key?(:namespace) },
          compile_options(options)
        )
      end
    end
  end
end
