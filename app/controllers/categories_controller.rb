class CategoriesController < ApplicationController

  prepend_before_action { authentication_check && authorize! }


  def index_service_catalog
    render json: ServiceCatalogItem.all
  end

  def show_service_catalog
    render json: ServiceCatalogItem.find_by(id: params[:id])
  end

  def index_service_catalog_sub_item
    if params[:parent_id]
      render json: ServiceCatalogSubItem.where(parent_service: params[:parent_id])
    else
      render json: ServiceCatalogSubItem.all
    end
  end

  def show_service_catalog_sub_item
    render json: ServiceCatalogSubItem.find_by(id: params[:id])
  end

  def index_asset
    render json: Asset.all
  end

  def show_asset
    render json: Asset.find_by(id: params[:id])
  end

end
