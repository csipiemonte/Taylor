Setting.create_if_not_exists(
  title:       'Defines postmaster filter.',
  name:        'ffff_classification_postmaster_filter_pre',
  area:        'Postmaster::PreFilter',
  description: 'Defines text-classification postmaster filter',
  options:     {},
  state:       'Channel::Filter::ClassificationFilter',
  frontend:    false
)

Setting.create_if_not_exists(
  title:       'Defines postmaster filter.',
  name:        'ffff_classification_postmaster_filter_post',
  area:        'Postmaster::PostFilter',
  description: 'Defines text-classification postmaster filter',
  options:     {},
  state:       'Channel::Filter::ClassificationFilter',
  frontend:    false
)

