# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

User.create_if_not_exists(
  login:         '-',
  firstname:     'NextCRM', #CSI Piemonte custom
  lastname:      '',
  email:         '',
  active:        false,
  updated_by_id: 1,
  created_by_id: 1
)

UserInfo.current_user_id = 1
