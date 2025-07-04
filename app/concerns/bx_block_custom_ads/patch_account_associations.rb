# frozen_string_literal: true

module BxBlockCustomAds
  module PatchAccountAssociations
    extend ActiveSupport::Concern

    included do
      belongs_to :role, class_name: 'BxBlockRolesPermissions::Role', required: false
    end
  end
end
