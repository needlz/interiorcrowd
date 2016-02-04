namespace :promocodes do
  desc 'load promocodes'
  task load: :environment do
    begin
      csv_file = ''
      ActiveRecord::Base.transaction do
        CSV.foreach(csv_file) do |row|
          if row[0] != 'Code'
            promocode_attributes = { promocode: row[0],
                                     display_message: row[1],
                                     active: true,
                                     discount_cents: row[3],
                                     discount_currency: 'USD',
                                     one_time: true }
            Promocode.create!(promocode_attributes)
          end
        end
      end
    rescue StandardError => e
      p e
    end
  end
end

