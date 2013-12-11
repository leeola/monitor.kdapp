# 
# # App Index
#
# This is a crazy ugly hack, i am aware, think of it as simply a proof of
# concept.
#

# A fake list of icons
ICONS =
  main    : 'koding.png'

# opts has events, i ugly as hell, but this is all for proof of concept atm.
html5_notify = (title, message, opts={}) ->
  opts.icon       ?=  ICONS.main
  opts.timeout    ?=  1000
  opts.show       ?=  false

  # Need to make this ff/etc friendly
  notifier = window.webkitNotifications

  # If we don't have permission, ask for it and bail.
  if notifier.checkPermission() isnt 0
    notifier.requestPermission (permission) ->
      console.log 'Request Permission:', permission
      if permission isnt "granted" then return
      html5_notify msg

  # Need a Koding icon 
  notification = notifier.createNotification icon, title, message
  notification.onclick    = opts.onclick
  notification.onclose    = opts.onclose
  notification.onerror    = (err) ->
    console.warn 'Monitor Error:', err
    opts.onerror() if opts.onerror?
  notification.ondisplay  = ->
    if not opts.timeout then return
    setTimeout (-> notification.close()), opts.timeout
    opts.ondisplay() if opts.ondisplay?

  notification.show() if opts.show
  notification

# Going to add multiple notification types
notify = html5_notify

monitor_new_activity = (callback=->) ->
  {groupChannel} = KD.getSingleton 'groupsController'
  groupChannel.on 'PostIsCreated', callback


do ->
  notify 'KDMonitor', 'Monitoring Activity', show: true
  KD.singletons.router.handleRoute '/Activity'

  monitor_new_activity (activity) ->
    notify 'Koding Activity', activity.subject.body[0...200]

