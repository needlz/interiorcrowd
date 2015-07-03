module ContestRequestMilestones

  class Generator

    def self.get(options)
      contest_status = options[:contest].status
      milestone_class =
        if contest_status == 'winner_selection'
          "ContestRequestMilestones::#{ contest_status.camelize }".constantize
        else
          "ContestRequestMilestones::#{ options[:contest_request].status.camelize }".constantize
        end
      milestone_class.new(options)
    end

  end

end
