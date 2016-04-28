module Breadcrumbs

  class Client < Base

    def my_contests
      self << { name: caption(:my_contests), href: urls_helper.client_center_entries_path }
    end

    def contest(contest, force_initial_phase_view = false)
      url_options = { id: contest.id }
      url_options.merge!(view: ContestPhases.phase_to_index(:initial)) if force_initial_phase_view
      self << { name: caption(:contest),
                href: urls_helper.client_center_entry_path(url_options) }
    end

    def profile
      self << { name: caption(:profile), href: urls_helper.client_center_profile_path }
    end

    def brief(contest)
      self << { name: caption(:brief), href: urls_helper.brief_contest_path(contest) }
    end

    def contest_request(contest_request)
      possessive = contest_request.designer.first_name.possessive
      self << { name: caption(:contest_request, possessive: possessive) }
    end

    private

    def caption(page, localization_params = nil)
      I18n.t("client_center.breadcrumbs.#{ page }", localization_params)
    end

  end

end
