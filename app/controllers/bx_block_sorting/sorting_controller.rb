# frozen_string_literal: true

module BxBlockSorting
  class SortingController < ApplicationController
    def index
      @catalogues = SortRecords.new(
        ::BxBlockCatalogue::Catalogue, params[:sorting]
      ).call
      render json: ::BxBlockCatalogue::CatalogueSerializer
        .new(@catalogues, serialization_options)
        .serializable_hash
    rescue StandardError
      @error = nil
      render json: { error: 'Unable to sort' }, status: 422
    end

    private

    def serialization_options
      { params: { host: request.protocol + request.host_with_port } }
    end
  end
end
