require 'cinch'

class Inspire
  include Cinch::Plugin

  set :prefix, /^!/

  match /inspire me$/, method: :inspire_me

  def inspire_help
    # spit out how this thing works!
  end

  def inspire_stats
    # spit out stats
  end

  def inspire_me(m)
    # targeted to the user
    #   - self motivation, improvement, value
  end

  def inspire_chat(m)
    # motivating for the entire chat
    #   - team-based, collaboration, togetherness
  end

  def inspire_hump_day(m)
    # something special to get you through the mid-week hump
  end

  def inspire_quote(m)
    # quote 
    #   - random quote pulled from inspiring people
  end
end
