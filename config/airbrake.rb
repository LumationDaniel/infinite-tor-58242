Airbrake.configure do |config|
  config.api_key = '6c0ced65d606abc9a0b69331ea56da03'
end

module ReportException
  protected
    def report_exception(e = nil)
      if e
        l = respond_to?(:logger) ? logger : (defined? Rails && Rails.logger)
        l.error("#{e.message}: #{e.backtrace * "\n"}") rescue nil
        Airbrake.notify(e)
        false
      else
        begin
          yield
          true
        rescue Exception => e
          report_exception(e)
          false
        end
      end
    end
end

Object.send :include, ReportException
