class VirtualAgentController < ApplicationController

  prepend_before_action { authentication_check && authorize! }

  def index
    render json: Role.where(name: 'Virtual Agent').first.users.where(active: true)
  end
end
