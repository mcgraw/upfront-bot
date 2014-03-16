require 'cinch'
require './models/CasinoPlayer'

class Bomb
	include Cinch::Plugin

	set :prefix, /^!/

	match /bomb help$/, method: :help
	match /bomb stat$/, method: :stat
	match /bomb play$/, method: :play
	match /bomb cut (.+)?/, method: :cut
	match /bomb leaderboard/, method: :leaderboard
	match /bomb reset$/, method: :reset_player

	@@debug = 0

	@@time_limit = -1
	@@player   = nil
	@@time     = 10
	@@prize    = 80
	@@penalty  = 50
	@@colors   = [ "red", "blue", "green", "yellow", "black", "purple" ]

	def help(m)
		# show help
		m.reply "This is BOMB. Cut the correct wire, earn $" + @@prize.to_s + "!!!"
		m.reply "--| !bomb play - We'll pass you over a bomb that needs dealt with"
		m.reply "--| !bomb cut <color> - Pick a color! Current colors: " + @@colors.join(', ')
		m.reply "--| !bomb stat - See how you're doing"
		m.reply "--| !bomb leaderboard - Who is KING BOMB?"
	end

	def stat(m) 
		player = find_player(m, m.user.nick)
		if player
			total = player.bombs_diffused.to_i + player.bombs_failed.to_i
			m.reply "Welcome back to BOMB " + player.name + ". $" + player.money.to_s + " remaining. Total plays: " + total.to_s + ". You have diffused " + player.bombs_diffused.to_s + " bombs, failed " + player.bombs_failed.to_s + " times." 
		else
			m.reply "It appears you are new. Try to not blow everything up, mmk? Type '!bomb play' to begin."
		end
	end

	def leaderboard(m)
		players = CasinoPlayer.all(:order => [ :money.asc ]).to_a

    	v = 0
    	players.map do |player| 
    		if v == 0
    			m.reply "The BOMB KING is " + player.name + " who has $" + player.money.to_s + "!"
    		elsif v < 3
    			m.reply "2nd place is " + player.name + "who has $" + player.money.to_s + "!"
    		end
    		v += 1
    	end
	end

	def play(m)
		if !@@player
			@@player = find_player(m, m.user.nick)
			if !@@player.bombs_solution
				@@player.bombs_solution = @@colors.sample

				m.reply @@player.name + " recieves the bomb. You have " + @@time.to_s + " seconds to deffuse it using by cutting the right cable. Choose you destiny (type !bomb cut <choice>): " + @@colors.join(', ')
				@@time_limit = Timer(@@time, { :method => :diffuse_failed, :shots => 1 })

				if @@debug == 1
					m.reply "[DEBUG] solution: " + @@player.bombs_solution
				end

				@@player.save
			else 
				m.reply "Um, you may want to diffuse the bomb you already have..."
			end
		else
			m.reply "Sorry " + m.user.nick + ", but " + @@player.name + " is diffusing a bomb out there."
		end
	end

	def cut(m, color)
		if @@player.bombs_solution
			@@time_limit.stop
			@@playing = 0

			if color == @@player.bombs_solution
				@@player.money = @@player.money.to_i + @@prize
				@@player.bombs_diffused += 1
				m.reply "GOT IT! Give " + @@player.name + " a pat on the back for not blowing everything up! Awarding $" + @@prize.to_s + "! " + @@player.money.to_s + " available" 
			else
				@@player.money = @@player.money.to_i - @@penalty 
				@@player.bombs_failed += 1

				if @@player.money < 0
					@@player.money = 0
				end

				m.reply "Sadly, " + @@player.name + " cut the wrong wire! It was " + @@player.bombs_solution + ". Taking $" + @@penalty.to_s + " to cover damages! $" + @@player.money.to_s + " remaining."
			end

			@@player.bombs_solution = nil
			@@player.save
			@@player = nil;
		end
	end

	def reset_player(m)
		player = find_player(m, m.user.nick)
		return if !player

		player.bombs_solution = nil
		player.bombs_failed = 0
		player.bombs_diffused = 0
		player.money = 500
		player.save

		@@player = nil;

    	m.reply "Reset " + player.name
	end

	protected

	def diffuse_failed
		@@player.bombs_solution = nil
		@@player.money = @@player.money - @@penalty
		@@player.save

		Channel("#moonlitech").send "The bomb explodes in front of " + @@player.name + ". Seems like you failed to notice the big beeping suitcase and lose $" + @@penalty.to_s + ". $" + @@player.money.to_s + " remaining."

		@@player = nil;
	end

	def find_player(m, nick)
		player = CasinoPlayer.first({ :name => nick })
		return player if player

		player = CasinoPlayer.create({ :name => nick, :money => 500 })
		player.bombs_solution = ""
		player.bombs_failed = 0
		player.bombs_diffused = 0

		m.reply "Welcome " + player.name + ". It appears that you have never played Bomb! Here is $" + player.money.to_s + " to get you started. Good luck!"

		player.save
		player
	end
end
