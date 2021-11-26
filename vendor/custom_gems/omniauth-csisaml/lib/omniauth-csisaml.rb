require 'omniauth-csisaml/version'
require 'omniauth'

module OmniAuth
  module Strategies
    # Autoload della omniauth strategy, deve avvenire con la prima lettera maiuscola
    autoload :Csisaml, 'omniauth/strategies/csisaml'
  end
end
