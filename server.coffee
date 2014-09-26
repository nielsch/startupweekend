Db = require 'db'
Plugin = require 'plugin'

exports.client_answer = (suggestionId, answer) ->
	log 'TODO save',  suggestionId, Plugin.userId(), Db.personal(Plugin.userId())
	Db.personal(Plugin.userId()).remove 'suggestions', suggestionId
