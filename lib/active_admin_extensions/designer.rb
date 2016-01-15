module ActiveAdminExtensions

  module Designer

    def self.months_for_years
      return @months if @months
      @months = { }
      (2014..2015).each { |year|
        Date::MONTHNAMES.drop(1).each { |month|
          menu_tab_name = month + ' ' + year.to_s
          @months[menu_tab_name] = Date.parse(menu_tab_name).strftime("%Y%m%d")
        }
      }
      @months
    end

    def self.range_limits_for_month(month)
      months_hash = months_for_years
      month_start_code = months_hash[month]
      month_start = Date.parse(months_hash[month])
      month_end_code = month_start.next_month.strftime("%Y%m%d")
      [month_start_code, month_end_code]
    end

  end

end
