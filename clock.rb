require "clockwork"
module Clockwork
  configure do |config|
    config[:sleep_timeout] = 5
  end

  handler do |job|
    puts "Running #{job}"
    puts `/plexupdate/plexupdate.sh -a -d -u`
    puts `supervisorctl restart plexmediaserver`
  end

  # every(1.day, 'plex.update', at: ["02:30", "12:00"])
  every(2.minute, 'plex.update')
end
