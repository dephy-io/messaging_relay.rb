# frozen_string_literal: true

class Pagy
  module Backends
    module Cursor
      extend Pagy::Backend

      private # the whole module is private so no problem with including it in a controller

      # Return Pagy object and limit
      def pagy_cursor(collection, vars = {})
        pagy = Pagy::Cursor.new(pagy_cursor_get_vars(collection, vars))

        limit = pagy_cursor_get_limit(collection, pagy, pagy.position)
        pagy.has_more = pagy_cursor_has_more?(limit, pagy)

        [pagy, limit]
      end

      def pagy_cursor_get_vars(collection, vars)
        pagy_get_limit_param(vars) if defined?(LimitExtra)

        vars[:arel_table] = collection.arel_table
        vars[:primary_key] = collection.primary_key
        vars[:backend] = "sequence"
        vars
      end

      def pagy_cursor_get_limit(collection, pagy, position = nil)
        if position.present?
          sql_comparison = pagy.arel_table[pagy.primary_key].send(pagy.comparison, position)
          collection.where(sql_comparison).reorder(pagy.order).limit(pagy.limit)
        else
          collection.reorder(pagy.order).limit(pagy.limit)
        end
      end

      def pagy_cursor_has_more?(collection, pagy)
        return false if collection.empty?

        next_position = collection.last[pagy.primary_key]
        pagy_cursor_get_limit(collection, pagy, next_position).exists?
      end
    end
  end
end
