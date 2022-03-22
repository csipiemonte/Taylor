# Copyright (C) 2012-2021 Zammad Foundation, http://zammad-foundation.org/

class FeaturesController < ApplicationController
  
  prepend_before_action :authentication_check

  def index
    list = Feature.all
    render json: list, status: :ok
  end

  def update
    feature = Feature.find(params[:id])
    feature.update_attributes(feature_params)
    render json: feature
  end

  private

  def feature_params
    params.require(:feature).permit(:enabled)
  end 

end
