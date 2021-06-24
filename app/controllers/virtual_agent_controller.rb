class VirtualAgentController < ApplicationController

  prepend_before_action { authentication_check && authorize! }

  def index
    virtual_agent = Role.find_by(name: 'Virtual Agent')
    return if not virtual_agent
    render json: virtual_agent.users.where(active: true)
  end
end
