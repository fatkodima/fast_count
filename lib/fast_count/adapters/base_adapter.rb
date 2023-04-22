# frozen_string_literal: true

module FastCount
  module Adapters
    # @private
    class BaseAdapter
      def initialize(connection)
        @connection = connection
      end

      def install; end
      def uninstall; end
    end
  end
end
