# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

module ZammadSpecSupportAvatarCheck

  def self.included(base)

    # Execute in RSpec class context
    base.class_exec do

      # This method disables the avatar for email check for all examples.
      #  It's possible to re-enable the check by adding the
      #  meta tag `perform_avatar_for_email_check` to the needing example:
      #
      # @example
      #  it 'does stuff with avatar check', perform_avatar_for_email_check: true do
      #
      before do |example|
        if !example.metadata[:perform_avatar_for_email_check]
          allow(Avatar).to receive(:auto_detection).and_return(false)
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include ZammadSpecSupportAvatarCheck
end
