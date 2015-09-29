module Breadcrumbs

  class Client < Base

    def my_contests
      self << { name: caption, href: urls_helper.client_center_entries_path }
    end

    def contest(contest, force_initial_phase_view = false)
      url_options = { id: contest.id }
      url_options.merge!(view: ContestPhases.phase_to_index(:initial)) if force_initial_phase_view
      self << { name: caption,
                href: urls_helper.client_center_entry_path(url_options) }
    end

    def profile
      self << { name: caption, href: urls_helper.client_center_profile_path }
    end

    def brief(contest)
      self << { name: caption, href: urls_helper.brief_contest_path(contest) }
    end

    def contest_request(contest_request)
      possessive = contest_request.designer.first_name.possessive
      self << { name: caption(possessive: possessive) }
    end

    private

    def caption(localization_params = nil)
      caller_method = caller_locations(1,1)[0].label
      I18n.t("client_center.breadcrumbs.#{ caller_method }", localization_params)
    end

  end

end
