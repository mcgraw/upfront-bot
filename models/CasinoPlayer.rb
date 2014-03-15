require 'dm-core'

class CasinoPlayer
	include DataMapper::Resource

	property :id, Serial
	property :name, String
	property :money, Integer

	# BOMB - Track how well things are going with the Bomb game
	property :bombs_solution, String
	property :bombs_diffused, Integer
	property :bombs_failed, Integer
end