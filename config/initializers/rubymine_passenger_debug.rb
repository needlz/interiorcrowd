# generated by RubyMine
debug_port = ENV['RUBYMINE_DEBUG_PORT']

if debug_port
  puts "Preparing to launch debugger for #{$$}"
  $:.push(*ENV['RUBYLIB'].split(":"))
  require 'ruby-debug-ide'

  Debugger.cli_debug = ("true" == ENV['RUBYMINE_DEBUG_VERBOSE'])
  Debugger.start_server('127.0.0.1', debug_port.to_i)
end