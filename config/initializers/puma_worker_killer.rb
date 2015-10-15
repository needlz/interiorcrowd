PumaWorkerKiller.config do |config|
  config.ram = 512 # mb
  config.frequency = 5 # seconds
  config.percent_usage = 0.95
end

PumaWorkerKiller.start
