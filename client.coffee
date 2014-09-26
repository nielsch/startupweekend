Db = require 'db'
Dom = require 'dom'
Modal = require 'modal'
Obs = require 'obs'
Plugin = require 'plugin'
Page = require 'page'
Server = require 'server'
Ui = require 'ui'
Form = require 'form'


renderSuggestion = (id, suggestion) !->
	Dom.h2 "Can you make it?"
	
	Dom.div !->
		Dom.text suggestion.what
		
	Dom.div !->
		Dom.text "@"
		Dom.text suggestion.where
		
	Ui.bigButton "YES", !->
		Server.call "answer", id, true
		
	Ui.bigButton "NO", !->
		Server.call "answer", id, false
		
renderNew = !->
	if Page.state.get(1) is 'what'
		Dom.text "WHAT?"
		
	else
		Dom.h2 "Who?"
		Plugin.users.iterate (user) !->
			Form.check
				name: user.key()
				text: user.get('name')
		
exports.render = ->
	if Page.state.get(0) is 'new'
		renderNew()
		return
	
	suggestions = Db.personal.get('suggestions')
	for k,v of suggestions
		renderSuggestion k, v
		return
		
	Dom.h2 "Hello, World!"

	Ui.bigButton "NEW EVENT", !->
		Page.nav 'new'
	
	Ui.list !->
		Db.shared.iterate 'events', (event) !->
			Ui.item !->
				Dom.text event.get('what')
	