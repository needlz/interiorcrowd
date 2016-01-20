module ActiveAdminExtensions

  module ContestDetails
    BEGINNING_YEAR = 2015

    def last_contest_status(user)
      contest = user.last_contest
      return '' unless contest
      if contest.status == 'incomplete'
        ContestShortDetails.new(contest).progress
      else
        contest.status
      end
    end

    def end_date(contest)
      if %w[finished closed].include? contest.status
        formatted_date(contest.status.to_s.capitalize + ' at ', contest.finished_at)
      end
    end

    def contest_name(contest)
      client = contest.client
      full_contest_name = link_to(full_user_name(client).possessive, admin_client_path(client)) + append_project_name(contest)
      full_contest_name.html_safe
    end

    def full_user_name(user)
      return user.first_name.to_s unless user.last_name
      return user.last_name.to_s unless user.first_name
      user.name
    end

    def append_project_name(contest)
      ' ' + contest.project_name.to_s + " (##{contest.id})"
    end

    def designers_list(requests)
      requests.map do |request|
        designer = request.designer
        statement = link_to(full_user_name(designer), admin_designer_path(designer))
        statement = yield(statement, request.submitted_at) if block_given?
        statement
      end.join('<br />').html_safe
    end

    def formatted_date(status_prefix, date)
      status_prefix + date.to_s if date
    end

    def winner_info(contest)
      if contest.response_winner
        designer = contest.response_winner.designer
        statement = link_to(full_user_name(designer), admin_designer_path(designer))
        statement = statement + formatted_date(', won at ', contest.response_winner.won_at)
        statement.html_safe
      end
    end

    def promocode_details(contest, detail)
      codes = contest.contest_promocodes
      codes.first.promocode.try(detail) if codes.present?
    end

    def self.months_for_years
      return @months if @months
      @months = { }
      (BEGINNING_YEAR..Date.current.year).each { |year|
        Date::MONTHNAMES.drop(1).each { |month|
          menu_tab_name = month + ' ' + year.to_s
          @months[menu_tab_name] = Date.parse(menu_tab_name).strftime("%Y%m%d")
        }
      }
      @months
    end

    def self.ranges_for_month(month)
      months_hash = months_for_years
      Date.parse(months_hash[month])
    end
  end

end
