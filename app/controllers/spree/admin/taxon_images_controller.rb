module Spree
  module Admin
    class TaxonImagesController < ResourceController
      before_action :load_edit_data, except: :index
      before_action :load_index_data, only: :index

      create.before :set_viewable
      update.before :set_viewable

      def create
        @image = Spree::Image.new(attachment: params[:image][:attachment], alt: params[:image][:alt])
        @image.viewable_type = 'Spree::Taxon'
        @image.viewable_id = params[:taxon_id]
        @image.save!

        redirect_to admin_taxonomy_taxon_images_url(@taxonomy, @taxon.id)
      end

      def index
        @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
      end

      def new
        @image = Spree::Image.new
      end

      def controller_name
        'taxon'
      end

      def update_positions
        Spree::Taxon.transaction do
          params[:positions].each do |id, index|
            Spree::Image.find(id).set_list_position(index)
          end
        end

        respond_to do |format|
          format.js { render plain: 'Ok' }
        end
      end

      private

      def location_after_destroy
        admin_taxonomy_taxon_images_url(@taxonomy, @taxon.id)
      end

      def location_after_save
        admin_taxonomy_taxon_images_url(@taxonomy, @taxon.id)
      end

      def load_index_data
        @taxon = Spree::Taxon.find(params[:taxon_id])
      end

      def load_edit_data
        @taxon = Spree::Taxon.find(params[:taxon_id])
        @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
      end

      def set_viewable
        @image = Spree::Image.new(attachment: params[:image][:attachment], alt: params[:image][:alt])
        @image.viewable_type = 'Spree::Taxon'
        @image.viewable_id = params[:taxon_id]
      end
    end
  end
end
