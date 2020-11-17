Zammad::Application.routes.draw do
  custom_api_path = '/api/custom/v1'

  match custom_api_path + '/knowledge_bases/:knowledge_base_id',   to: 'knowledge_bases_custom#kb_settings', via: :get
  match custom_api_path + '/knowledge_bases/:knowledge_base_id/categories',   to: 'knowledge_bases_custom#index_categories', via: :get
  match custom_api_path + '/knowledge_bases/:knowledge_base_id/categories/:category_id/',   to: 'knowledge_bases_custom#show_category', via: :get

end
