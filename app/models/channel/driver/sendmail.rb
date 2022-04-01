# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class Channel::Driver::Sendmail
  def send(_options, attr, notification = false)

    # return if we run import mode
    return if Setting.get('import_mode')

    # set system_bcc of config if defined
    system_bcc = Setting.get('system_bcc')
    email_address_validation = EmailAddressValidation.new(system_bcc)
    if system_bcc.present? && email_address_validation.valid_format?
      attr[:bcc] ||= ''
      attr[:bcc] += ', ' if attr[:bcc].present?
      attr[:bcc] += system_bcc
    end

    mail = Channel::EmailBuild.build(attr, notification)
    
    mail.delivery_method delivery_method
    
    # CSI custom - log invio mail
    res = mail.deliver
    Rails.logger.info "[Channel::Driver::Sendmail] Sending mail:\n\tTo: #{res.to}\n\tFrom: #{res.from}\n\tSubject: #{res.subject}\n\tDate: #{res.date}\n\tBody:\n#{res.body.to_s[0...500]}\n\tMessage-id: #{res.message_id}"
    
    res
  end

  private

  def delivery_method
    return :test if Rails.env.test?

    :sendmail
  end
end
