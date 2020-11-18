class KnowledgeBasesCustomController < ApplicationController
 prepend_before_action { authentication_check && authorize! }

 def active
  render json: KnowledgeBase.where(active: true).as_json(only: [:id])
 end

 def index_categories
  root_categories = KnowledgeBase::Category.where("knowledge_base_id = #{params[:knowledge_base_id]} AND parent_id is NULL").as_json(except: [:created_at, :updated_at])
  filtered_categories = []
  root_categories.each do |category|
    filtered_categories << category if is_to_show(category,params[:status])
  end
  filtered_categories.each do |category|
    name = KnowledgeBase::Category::Translation.find_by(category_id: category['id'])[:title]
    category[:name] = name
  end
  render json: filtered_categories
 end

 def show_category
  category = KnowledgeBase::Category.find_by(id: params[:category_id]).as_json(except: [:created_at, :updated_at])
  if is_to_show(category,params[:status])
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
    filtered_children = []
    children.each do |child|
      filtered_children << child if is_to_show(child,params[:status])
      child_name = KnowledgeBase::Category::Translation.find_by(category_id: child['id'])[:title]
      child[:name] = child_name
    end
    render json:{
      category: category,
      answers: answers,
      children: filtered_children
    }
  else
    render json:{}
  end
 end

 def kb_settings
  knowledge_base = KnowledgeBase.find_by(id: params[:knowledge_base_id]).as_json(except: [:created_at, :updated_at])
  render json: knowledge_base
 end

 private

 def is_to_show(category, show_setting)
  show_setting = show_setting ? show_setting : 'published'
  return show_setting == 'all' ? true : show_setting == 'published' ? is_published(category) : show_setting == 'unpublished' ? !is_published(category) : false
 end

 def is_published(category)
  return false if !category['id']
  answers = KnowledgeBase::Answer.where("category_id = #{category['id']} AND published_at IS NOT NULL")
  return true if answers.length > 0
  children = KnowledgeBase::Category.where(parent_id: category['id']).as_json
  children.each do |child|
    return true if is_published child
  end
  false
 end

end
