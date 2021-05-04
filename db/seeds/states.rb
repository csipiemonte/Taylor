pending_close = Ticket::State.find_by(name: 'pending close')
pending_close.active = false
pending_close.save!
pending_reminder = Ticket::State.find_by(name: 'pending reminder')
pending_reminder.active = false
pending_reminder.save!

if !Ticket::State.find_by(name:'resolved')
  Ticket::State.create_if_not_exists(
       name: 'resolved',
       state_type: Ticket::StateType.find_by(name: 'open'),
       ignore_escalation: true,
       created_by_id: 1,
       updated_by_id: 1,
       active: true
  )
end

if !Ticket::State.find_by(name:'pending user feedback')
  Ticket::State.create_if_not_exists(
       name: 'pending user feedback',
       state_type: Ticket::StateType.find_by(name: 'open'),
       created_by_id: 1,
       updated_by_id: 1,
       ignore_escalation: true,
       active: true
  )
end

if !Ticket::State.find_by(name:'pending external activity')
  Ticket::State.create_if_not_exists(
       name: 'pending external activity',
       state_type: Ticket::StateType.find_by(name: 'open'),
       created_by_id: 1,
       updated_by_id: 1,
       external_state_id: 2,
       ignore_escalation: true,
       active: true
  )
end

attribute = ObjectManager::Attribute.get(
   object: 'Ticket',
   name: 'state_id',
 )
attribute.data_option[:filter] = Ticket::State.by_category(:viewable).where(active: [true]).pluck(:id)
attribute.screens[:create_middle]['ticket.agent'][:filter] = Ticket::State.by_category(:viewable_agent_new).where(active: [true]).pluck(:id)
attribute.screens[:create_middle]['ticket.customer'][:filter] = Ticket::State.by_category(:viewable_customer_new).where(active: [true]).pluck(:id)
attribute.screens[:edit]['ticket.agent'][:filter] = Ticket::State.by_category(:viewable_agent_edit).where(active: [true]).pluck(:id)
attribute.screens[:edit]['ticket.customer'][:filter] = Ticket::State.by_category(:viewable_customer_edit).where(active: [true]).pluck(:id)
attribute.save!

Translation.create_if_not_exists(
  locale: 'it-it',
  source: 'resolved',
  target: 'risolto',
  target_initial: 'risolto',
  format: 'string',
  created_by_id: '1',
  updated_by_id: '1',
)

Translation.create_if_not_exists(
  locale: 'it-it',
  source: 'pending user feedback',
  target: 'in attesa di informazioni da utente',
  target_initial: 'in attesa di informazioni da utente',
  format: 'string',
  created_by_id: '1',
  updated_by_id: '1',
)

Translation.create_if_not_exists(
  locale: 'it-it',
  source: 'pending external activity',
  target: 'in attesa di lavorazione esterna',
  target_initial: 'in attesa di lavorazione esterna',
  format: 'string',
  created_by_id: '1',
  updated_by_id: '1',
)

if !Job.find_by(name: 'auto-close resolved tickets')
  Job.create!(
    name: 'auto-close resolved tickets',
    timeplan: {
      'days' => {
        'Mon': true,
        'Tue': true,
        'Wed': true,
        'Thu': true,
        'Fri': true,
        'Sat': true,
        'Sun': true,
      },
      'hours' => {
        '0': true,
        '1': true,
        '2': true,
        '3': true,
        '4': true,
        '5': true,
        '6': true,
        '7': true,
        '8': true,
        '9': true,
        '10': true,
        '11': true,
        '12': true,
        '13': true,
        '14': true,
        '15': true,
        '16': true,
        '17': true,
        '18': true,
        '19': true,
        '20': true,
        '21': true,
        '22': true,
        '23': true,
      },
      'minutes' => {
        '0': true,
        '10': true,
        '20': true,
        '30': true,
        '40': true,
        '50': true,
      }
    },
    condition:            {
      'ticket.updated_at' =>{
        'operator' => 'before (relative)',
        'value': '1',
        'range': 'hour'
      },
      'ticket.state_id' => {
        'operator' => 'is',
        'value'    => Ticket::State.lookup(name: 'resolved').id.to_s,
      }
    },
    perform:              {
      'ticket.state_id' => {
        value: Ticket::State.lookup(name: 'closed').id.to_s,
      }
    },
    disable_notification: true,
    active:               true,
    created_by_id:        1,
    updated_by_id:        1,
  )
end
