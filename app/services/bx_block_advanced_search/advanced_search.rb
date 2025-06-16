# frozen_string_literal: true

module BxBlockAdvancedSearch
  module AdvancedSearch
    def self.search(first_name:, last_name:)
      where_clause = AccountBlock::Account.where("")
      where_clause = where_clause.where("lower(first_name) ilike ?", "#{first_name}%") if first_name.present?
      where_clause = where_clause.where("lower(last_name) ilike ?", "#{last_name}%") if last_name.present?
      where_clause
    end
  end
end
