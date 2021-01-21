module OmniAuth
  module Strategies
    # The Developer strategy is a very simple strategy that can be used as a
    # placeholder in your application until a different authentication strategy
    # is swapped in. It has zero security and should *never* be used in a
    # production setting.
    #
    # ## Usage
    #
    # To use the Developer strategy, all you need to do is put it in like any
    # other strategy:
    #
    # @example Basic Usage
    #
    #   use OmniAuth::Builder do
    #     provider :developer
    #   end
    #
    # @example Custom Fields
    #
    #   use OmniAuth::Builder do
    #     provider :developer,
    #       :fields => [:first_name, :last_name],
    #       :uid_field => :last_name
    #   end
    #
    # This will create a strategy that, when the user visits `/auth/developer`
    # they will be presented a form that prompts for (by default) their name
    # and email address. The auth hash will be populated with these fields and
    # the `uid` will simply be set to the provided email.
    class Csimodshib
      include OmniAuth::Strategy

      option :fields, %i[
        Shib-Identita-Nome 
        Shib-Identita-Cognome 
        Shib-Identita-CodiceFiscale
        Shib-community 
        Shib-Identita-TimeStamp 
        Shib-Identita-LivAuth 
        Codice-identificativo-SPID
      ]

      option :info_headers, {
        uid: 'Codice-identificativo-SPID',
        name: 'Shib-Identita-Nome', 
        first_name: 'Shib-Identita-Nome', 
        last_name: 'Shib-Identita-Cognome', 
        # Shib-Identita-CodiceFiscale,
        # Shib-community, 
        # Shib-Identita-TimeStamp ,
        # Shib-Identita-LivAuth ,
      }


      option :uid_field, 'Codice-identificativo-SPID'

      def request_phase
        # form = OmniAuth::Form.new(:title => 'User Info', :url => callback_path)
        # options.info_headers.each do |key, field|
        #   form.text_field field.to_s.capitalize.tr('_', ' '), field.to_s
        # end
        # form.button 'Sign In'
        # form.to_response
        
        #raise ::OmniAuth::Error, 'request phase deve essere inoltrata da mod_shib apache'

        [ 
          302,
          {
            'Location' => script_name + callback_path + query_string,
            'Content-Type' => 'text/plain'
          },
          ["You are being redirected to Shibboleth SP/IdP for sign-in."]
        ]
      end

      def callback_phase
        super
      end

      uid do
        # request.params[options.uid_field.to_s]
        fetch_header options.uid_field
      end

      info do
        # res1 = options.fields.inject({}) do |hash, field|
        #   hash[field] = request.params[field.to_s]
        #   hash
        # end

        res = options.info_headers.each_with_object({}) do |(attribute, header), info|
          info[attribute] = fetch_header header
        end

        res
      end

      private

      def fetch_header(header)
        request.env.fetch "HTTP_#{header.upcase.gsub('-', '_')}"
      end

    end
  end
end
