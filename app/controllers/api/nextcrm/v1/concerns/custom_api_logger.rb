# Copyright (C) 2020-2022 CSI Piemonte, https://www.csipiemonte.it/

module Api::Nextcrm::V1::Concerns::CustomApiLogger
  extend ActiveSupport::Concern

  def apilogger
    APILogger.new(
      {
        request:      request,
        current_user: current_user
      }
    )
  end

  class APILogger < Logger

    def initialize(context = {})
      @context = context
    end

    def debug(progname = '', &block)
      level = Logger::DEBUG
      rails_logger_call(level, progname, &block)
    end

    def info(progname = '', &block)
      level = Logger::INFO
      rails_logger_call(level, progname, &block)
    end

    def warn(progname = '', &block)
      level = Logger::WARN
      rails_logger_call(level, progname, &block)
    end

    def error(progname = '', &block)
      level = Logger::ERROR
      rails_logger_call(level, progname, &block)
    end

    def fatal(progname = '', &block)
      level = Logger::FATAL
      rails_logger_call(level, progname, &block)
    end

    private

    def rails_logger_call(level = nil, progname = '', &block)
      if not block_given?
        # se il messaggio non 'e fornito un block ma in un argomento normail, la libreria di log di rails
        # interpreta il primo argomento come il messaggio anziche' come progname e si aspetta di avere la variabile
        # progname nulla. in questo caso creo io il block per replicare il comportamento standard
        message = progname
        block = Proc.new { message }
        progname = ''
      end
      request_id = @context[:request].uuid
      remote_ip = @context[:request].remote_ip
      current_user_id = @context[:current_user] ? @context[:current_user].id : 'null'
      progname += "[API remote_ip: #{remote_ip} request_id:#{request_id} user_id:#{current_user_id}]"
      # https://github.com/ruby/logger/blob/master/lib/logger.rb#L494
      Rails.logger.add(level, nil, progname, &block)
    end
  end
end
