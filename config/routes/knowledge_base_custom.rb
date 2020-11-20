Zammad::Application.routes.draw do
  custom_api_path = '/api/custom/v1'

  match custom_api_path + '/knowledge_bases',   to: 'knowledge_bases_custom#active', via: :get
  match custom_api_path + '/knowledge_bases/:knowledge_base_id',   to: 'knowledge_bases_custom#kb_settings', via: :get
  match custom_api_path + '/knowledge_bases/:knowledge_base_id/categories',   to: 'knowledge_bases_custom#index_categories', via: :get
  match custom_api_path + '/knowledge_bases/:knowledge_base_id/categories/:category_id/',   to: 'knowledge_bases_custom#show_category', via: :get
  match custom_api_path + '/knowledge_bases/:knowledge_base_id/categories/:category_id/answers',   to: 'knowledge_bases_custom#index_answers', via: :get
  match custom_api_path + '/knowledge_bases/:knowledge_base_id/categories/:category_id/answers/:answer_id',   to: 'knowledge_bases_custom#show_answer', via: :get

end
