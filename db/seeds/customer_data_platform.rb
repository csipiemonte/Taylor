# cdp unomi

# NEXTCRM features toggle on/off
Setting.create_if_not_exists(
  title:       'Customer Data Platform profile',
  name:        'cdp_profile',
  area:        'System::Features',
  description: 'Enable feature CDP profile',
  options:     {},
  state:  false, 
  preferences: {
    prio:       2,
    permission: ['admin.integration'],
  },
  frontend:    true,
)



def create_translation(locale, source, target)
  Translation.create_if_not_exists(
    locale:         locale,
    source:         source,
    target:         target,
    target_initial: target,
    format:         'string',
    created_by_id:  '1',
    updated_by_id:  '1',
  )
end
create_translation('it-it', 'Event List', 'Lista Eventi')
create_translation('it-it', 'Scope', 'Ambito')
create_translation('it-it', 'Source Type', 'Tipo Origine')
create_translation('it-it', 'Source Name', 'Nome Origine')