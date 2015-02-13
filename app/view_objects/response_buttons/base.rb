module ResponseButtons
  class Base
    include Rails.application.routes.url_helpers

    attr_reader :response_id

    def self.from_response(contest_response)
      status = contest_response.status
      status[0] = status[0].capitalize
      klass = Object.const_get "ResponseButtons::#{ status }Buttons"
      klass.new(contest_response.id)
    end

    def initialize(response_id)
      @response_id = response_id
    end

  end
end