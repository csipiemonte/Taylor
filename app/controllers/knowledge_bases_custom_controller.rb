class KnowledgeBasesCustomController < ApplicationController

 def index_categories
  root_categories = KnowledgeBase::Category.where("knowledge_base_id = #{params[:knowledge_base_id]} AND parent_id is NULL").as_json(except: [:created_at, :updated_at])
  root_categories.each do |category|
    name = KnowledgeBase::Category::Translation.find_by(category_id: category['id'])[:title]
    category[:name] = name
  end
  render json: root_categories
 end

 def show_category
  category = KnowledgeBase::Category.find_by(id: params[:category_id]).as_json(except: [:created_at, :updated_at])
  name = KnowledgeBase::Category::Translation.find_by(category_id: params[:category_id])[:title]
  category[:name] = name
  answers = KnowledgeBase::Answer.where(category_id: params[:category_id]).as_json(only: [:id, :title])
  answers.each do |answer|
    answer_title = KnowledgeBase::Answer::Translation.find_by(answer_id: answer['id'])
    answer_content = KnowledgeBase::Answer::Translation::Content.find_by(id: answer_title[:content_id])
    answer[:title] = answer_title[:title]
    answer[:body] = answer_content[:body]
  end
  children = KnowledgeBase::Category.where(parent_id: params[:category_id]).as_json(except: [:created_at, :updated_at])
  children.each do |child|
    child_name = KnowledgeBase::Category::Translation.find_by(category_id: params[:category_id])[:title]
    child[:name] = child_name
  end
  render json:{
    category: category,
    answers: answers,
    children: children
  }
 end

 def kb_settings
  knowledge_base = KnowledgeBase.find_by(id: params[:knowledge_base_id]).as_json(except: [:created_at, :updated_at])
  render json: knowledge_base
 end

end
