Db = require 'db'
Plugin = require 'plugin'

exports.client_answer = (askId, answer) !->
	[eventId, time] = askId.split('.')
	Db.personal(Plugin.userId()).remove 'ask', askId
	Db.shared.set 'events', eventId, 'users', Plugin.userId(), time, answer

exports.client_new = (values) !->
	eventId = Db.shared.modify 'eventId', (v) -> (v||0) + 1
	users = values.users
	delete values.users
	Db.shared.set 'events', eventId, values

	# for now, just schedule ahead 24h, 48h, 96h
	for offset in [24, 48, 96]
		time = Date.now() + offset*3600*1000
		for userId in users
			Db.shared.set 'events', eventId, 'users', userId, time, false
			Db.personal(userId).set 'ask', eventId+'.'+time, true
