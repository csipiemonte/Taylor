# Copyright (C) 2012-2021 Zammad Foundation, http://zammad-foundation.org/

class KnowledgeBase::Answer::Translation::Content < ApplicationModel
  include HasAgentAllowedParams
  include HasRichText

  AGENT_ALLOWED_ATTRIBUTES = %i[body].freeze

  has_one :translation, class_name: 'KnowledgeBase::Answer::Translation', inverse_of: :content, dependent: :nullify

  has_rich_text :body

  attachments_cleanup!

  def visible?
    translation.answer.visible?
  end

  def visible_internally?
    translation.answer.visible_internally?
  end

  delegate :created_by_id, to: :translation

  def attributes_with_association_ids
    attrs = super
    add_attachments_to_attributes(attrs)
  end

  def attributes_with_association_names(empty_keys: false)
    attrs = super
    add_attachments_to_attributes(attrs)
  end

  def add_attachments_to_attributes(attributes)
    attributes['attachments'] = attachments
                                .reject { |file| HasRichText.attachment_inline?(file) }
                                .map(&:attributes_for_display)

    attributes
  end

  def search_index_attribute_lookup(include_references: true)
    attrs = super
    attrs['body'] = ActionController::Base.helpers.strip_tags attrs['body']
    attrs
  end

  private

  def touch_translation
    translation&.touch # rubocop:disable Rails/SkipsModelValidations
  end

  before_save :sanitize_body
  after_save  :touch_translation
  after_touch :touch_translation

  def sanitize_body
    self.body = HtmlSanitizer.dynamic_image_size(body)
    self.body = text_sanitizer(body)
  end

  #custom csi
  def text_sanitizer(text)
    # check unicode characters like bold or italic letters and normalize the string
    unless text.unicode_normalized?(:nfkc)
      text = text.unicode_normalize(:nfkc)
    end
    # since new emoji are created every year, it is impossible to create a regex that matches each new one,
    # this will remove any emoji or non basic unicode characters.
    # Other Unicode characters, such as Asian characters, are preserved.
    regex = /[^[:alnum:][:blank:][:punct:]\n¥£€°]/
    if (text =~ regex).nil? # checks if the string match the regex
      text # returns the original string with no changes
    else
      text.gsub(regex, '').squeeze(' ').strip
    end
  end

end
