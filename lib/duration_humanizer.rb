class DurationHumanizer

  def self.to_string(view_context, start_time, end_time)
    phase_end_time = end_time || start_time
    distance = phase_end_time - start_time
    display_options =
        if distance > 2.days
          phase_end_time = start_time + (distance / 1.day).floor.days
          { vague: true }
        else
          { highest_measures: 2 }
        end
    view_context.distance_of_time_in_words(start_time,
                                           phase_end_time,
                                           display_options)
  end

end
