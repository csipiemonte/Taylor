if Channel.all.length < 1
  Channel.create_if_not_exists(
    id: 1,
    area:        'Email::Notification',
    options:     {
      outbound: {
        adapter: 'smtp',
        options: {
          host:     'host.example.com',
          user:     '',
          password: '',
          ssl:      true,
        },
      },
    },
    group_id:    1,
    preferences: { online_service_disable: true },
    active:      false,
  )
  Channel.create_if_not_exists(
    id: 2,
    area:        'Email::Notification',
    options:     {
      outbound: {
        adapter: 'sendmail',
      },
    },
    preferences: { online_service_disable: true },
    active:      true,
  )
end
