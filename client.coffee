Db = require 'db'
Dom = require 'dom'
Modal = require 'modal'
Obs = require 'obs'
Plugin = require 'plugin'
Page = require 'page'
Server = require 'server'
Ui = require 'ui'
Form = require 'form'
Time = require 'time'


renderAsk = (key, ask) !->
	Dom.h2 "Can you make it?"

	[eventId, time] = key.split '.'
	log 'RENDER ASK', key, eventId, time

	event = Db.shared.get 'events', eventId
	
	Dom.div !->
		Time.deltaText time*.001

	Dom.div !->
		Dom.text event.what
		
	if event.where
		Dom.div !->
			Dom.text "@"
			Dom.text event.where 
		
	Ui.bigButton "YES", !->
		Server.call 'answer', key, 'yes'
		
	Ui.bigButton "NO", !->
		Server.call 'answer', key, 'no'
		
renderNew = !->
	step = Obs.create()
	users = {}
	Obs.observe !->
		if step.get() is 'what'
			Dom.h2 "What are you going to do?"

			Form.input
				name: 'what'
				text: 'Activity description'

			Form.setPageSubmit (values) !->
				values.users = users
				log 'submit', values
				Server.call 'new', values
				Page.back()
			, true

		else
			Dom.h2 "Who might participate?"
			Plugin.users.iterate (user) !->
				Form.check
					name: user.key()
					text: user.get('name')
					value: true

			Form.setPageSubmit (values) !->
				users = []
				users.push u for u,v of values when v
				step.set 'what'
			, true

renderEvent = (event, key) !->
	Dom.h1 "Event: " + event.get('what')

	Dom.h2 "Status"
	if time = event.get('when')
		Dom.div "Date is picked @ "
		Time.deltaText time
	else
		Dom.div "Still gathering responses"

	Dom.h2 "Participants"
	Ui.list !->
		event.iterate 'users', (user) !->
			Ui.item !->
				userId = user.key()
				Ui.avatar Plugin.userAvatar(userId)

				y = 0
				y++ for k,v of user.get() when v is 'yes'

				n = 0
				n++ for k,v of user.get() when v is 'no'

				u = 0
				u++ for k,v of user.get() when v not in ['yes', 'no']

				Dom.div !->
					Dom.text Plugin.userName(userId)

					Dom.text " (YES: #{y}x, NO: #{n}x, UNANSWERED: #{u})"

				if u
					Form.vSep()
					Dom.div !->
						Dom.style
							display_: 'box'
							position: 'relative'
							_boxPack: 'center'
							_boxAlign: 'center'
							padding: '14px'
							width: '32px'
							color: '#72bb53'
						Dom.text "nudge!"
						Dom.onTap !->
							Server.call "nudge", key(), userId





exports.render = ->
	if Page.state.get(0) is 'new'
		renderNew()
		return

	if Page.state.get(0) is 'event' and e = Db.shared.ref('events', Page.state.get(1))
		renderEvent e, Page.state.get(1)
		return
	
	for k,v of Db.personal.get('ask')
		renderAsk k, v
		return

	Dom.h2 "Planned events"

	Ui.bigButton "Add new event", !->
		Page.nav 'new'
	
	Ui.list !->
		Db.shared.iterate 'events', (event) !->
			Ui.item !->
				Dom.text event.get('what')
				Dom.onTap !->
					Page.nav ['event', event.key()]
		, (event) -> -event.key()
