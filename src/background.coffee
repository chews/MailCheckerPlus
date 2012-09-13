#/ <reference path="chrome-api-vsdoc.js" />
#/ <reference path="jquery-1.4.2.js" />
#/ <reference path="mailaccount.class.js" />

img_notLoggedInSrc = "not_logged_in"
img_noNewSrc = "no_new"
img_newSrc = "new"
iconSet = "set1"
iconFormat = ".png"
accounts = undefined
unreadCount = undefined
accountWithNewestMail = undefined
profilePhotos = undefined
canvas = undefined
canvasContext = undefined
gfx = undefined
rotation = 1
factor = 1
animTimer = undefined
loopTimer = undefined
animDelay = 10
audioElement = new Audio()

startAnimate = ->
  if not localStorage?.gc_animate_off or localStorage.gc_animate_off is "false"
    stopAnimateLoop()
    animTimer = setInterval doAnimate, animDelay
    setTimeout stopAnimate, 2000
    loopTimer = setInterval startAnimate, 20000

stopAnimate = ->
  clearTimeout animTimer if animTimer?
  if unreadCount > 0
    setIcon img_newSrc
  else
    setIcon img_noNewSrc
  rotation = 1
  factor = 1

stopAnimateLoop = ->
  clearTimeout loopTimer if loopTimer?
  stopAnimate()

doAnimate = ->
  canvasContext.save()
  canvasContext.clearRect 0, 0, canvas.width, canvas.height
  canvasContext.translate Math.ceil(canvas.width / 2), Math.ceil(canvas.height / 2)
  canvasContext.rotate rotation * 2 * Math.PI
  canvasContext.drawImage gfx, -Math.ceil(canvas.width / 2), -Math.ceil(canvas.height / 2)
  canvasContext.restore()
  rotation += 0.01 * factor
  if rotation <= 0.9 and factor < 0
    factor = 1
  else if rotation >= 1.1 and factor > 0
    factor = -1
  chrome.browserAction.setIcon imageData: canvasContext.getImageData(0, 0, canvas.width, canvas.height)

migrateSettings = ->
  if not localStorage.gc_open_label? or not localStorage.gc_check_label?
    # Backwards compatability with previous checkboxes
    delete localStorage.gc_open_label

    if localStorage.gc_check_all? and localStorage.gc_check_all is "true"
      # Check all mail
      localStorage.gc_check_label = "unread"
      localStorage.gc_open_label = "#search/l:unread"
      delete localStorage.gc_check_all
    else if localStorage.gc_check_priority? and localStorage.gc_check_priority is "true"
      # Check priority mail
      localStorage.gc_check_label = "important"
      localStorage.gc_open_label = "#mbox"
      delete localStorage.gc_check_priority
    else
      # Default settings (inbox)
      localStorage.gc_check_label = ""
      localStorage.gc_open_label = "#inbox"  

reloadSettings = ->
  unreadCount = 0

  localStorage.gc_poll ?= 15000
  localStorage.gc_dn_timeout ?= 15000
  localStorage.gc_sn_audio ?= "chime.mp3"

  migrateSettings()
  reloadLanguage()

  iconSet = localStorage.gc_icon_set
  iconSet = localStorage.gc_icon_set = "set12"  if not iconSet? or iconSet is ""
  setIcon img_notLoggedInSrc

  chrome.browserAction.setBadgeBackgroundColor color: [190, 190, 190, 255]
  chrome.browserAction.setBadgeText text: "?"
  chrome.browserAction.setTitle title: "Loading settings..."

  if not localStorage.gc_preview_setting? or localStorage.gc_preview_setting is ""
    localStorage.gc_preview_setting = "2"

  if not localStorage.gc_show_notification? or localStorage.gc_show_notification is ""
    localStorage.gc_show_notification = "true"

  if not localStorage.gc_version? or localStorage.gc_version isnt "1.2.2"
    localStorage.gc_version = "1.2.2"
    chrome.tabs.create url: "about.html"

  if accounts?
    for account in accounts
      account.stopScheduler()

  accounts = []
  profilePhotos = {}

  chrome.browserAction.setBadgeText text: "..."
  chrome.browserAction.setTitle title: "Polling accounts..."

  if not localStorage.gc_check_gmail_off? or localStorage.gc_check_gmail_off is "false"
    # Check if user has enabled multiple sessions
    $.ajax
      url: "https://www.google.com/accounts/AddSession"

      success: (data) ->        
        # Multiple accounts active
        if matches = data.match(/([\S]+?@[\S]+)/g)
          for match, n in matches
            acc = new MailAccount(accountNr: n)
            acc.onError = mailError
            acc.onUpdate = mailUpdate
            accounts.push acc
        reloadSettings_complete()

      complete: ->  
        if accounts.length is 0        
          # No multiple accounts - just check default Gmail
          acc = new MailAccount({})
          acc.onError = mailError
          acc.onUpdate = mailUpdate
          accounts.push acc
          reloadSettings_complete()
  else
    reloadSettings_complete()

reloadSettings_complete = ->
  if localStorage.gc_accounts?
    savedAccounts = JSON.parse(localStorage.gc_accounts)
    for savedAccount in savedAccounts
      return unless savedAccount.domain?
      acc = new MailAccount(domain: savedAccount.domain)
      acc.onError = mailError
      acc.onUpdate = mailUpdate
      accounts.push acc
  stopAnimateLoop()
  gfx.src = "icons/" + iconSet + "/new" + iconFormat
  
  # Start request loop
  window.setTimeout startRequest, 0

# Sets the browser action icon
setIcon = (iconName) ->
  fullPath = "icons/" + iconSet + "/" + iconName + iconFormat
  try
    chrome.browserAction.setIcon path: fullPath
  catch e
    console.error "Could not set browser action icon '#{fullPath}'."

# Request loop starter
startRequest = ->
  for account in accounts
    if account?
      window.setTimeout account.startScheduler, 500 * i

# Called when an account has received a mail update
mailUpdate = (_account) ->
  stopAnimateLoop()
  hideCount = localStorage.gc_hide_count
  newUnreadCount = 0

  for account in accounts
    if account? and account.getUnreadCount() > 0
      newUnreadCount += account.getUnreadCount()

  if _account.getNewestMail()?
    accountWithNewestMail = _account

  if hideCount is "true" or newUnreadCount < 1
    chrome.browserAction.setBadgeText text: ""
  else
    chrome.browserAction.setBadgeText text: newUnreadCount.toString()

  switch newUnreadCount
    when 0
      setIcon img_noNewSrc
      chrome.browserAction.setBadgeBackgroundColor color: [110, 140, 180, 255]
      chrome.browserAction.setTitle title: i18n.get("noUnreadText")
    when 1
      setIcon img_newSrc
      chrome.browserAction.setBadgeBackgroundColor color: [200, 100, 100, 255]

      if i18n.get("oneUnreadText")
        unreadText = i18n.get "oneUnreadText"
      else 
        unreadText = i18n.get "severalUnreadText"

      chrome.browserAction.setTitle title: newUnreadCount + " " + unreadText
    else
      setIcon img_newSrc
      chrome.browserAction.setBadgeBackgroundColor color: [200, 100, 100, 255]
      chrome.browserAction.setTitle title: newUnreadCount + " " + i18n.get("severalUnreadText")

  if newUnreadCount > unreadCount
    setTimeout playSound, 0
    setTimeout startAnimate, 0

    if accountWithNewestMail?
      setTimeout notify accountWithNewestMail, 0
  unreadCount = newUnreadCount

# Called when an account has experienced an error
mailError = ->
  setIcon img_notLoggedInSrc
  chrome.browserAction.setBadgeBackgroundColor color: [190, 190, 190, 255]
  chrome.browserAction.setBadgeText text: "X"
  chrome.browserAction.setTitle title: "Not logged in"
  unreadCount = 0

# Plays a ping sound
playSound = ->
  if localStorage.gc_sound_off
    return
  source = localStorage.gc_sn_audio

  if source is "custom"
    source = localStorage.gc_sn_audio_raw
  try
    audioElement.src = source
    audioElement.load()
    audioElement.play()
  catch e
    console.error e

# Displays a notification popup
notify = ->
  if localStorage.gc_show_notification
    try
      notification = webkitNotifications.createHTMLNotification chrome.extension.getURL "notify.html"
      timeout = localStorage.gc_dn_timeout
      notification.show()
      if timeout isnt 0
        setTimeout notification.cancel, timeout
    catch e
      console.error e

getLabels = (mailURL, callback) ->
  getURL = mailURL + "h/" + Math.ceil(1000000 * Math.random()) + "/?v=prl"
  $.ajax
    url: getURL
    success: (data) ->
      labelArray = []
      labelPage = $(data)
      labels = $("div.prf > table > tbody > tr > td > b > a", labelPage)
      labels.each (i) ->
        labelArray.push $(this)[0].innerText

      if callback?
        setTimeout callback(labelArray), 0
  
chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  openInTab = localStorage.gc_open_tabs
  disableMailTo = localStorage.gc_no_mailto

  if request.getNewMail
    sendResponse
      mailAccount: accountWithNewestMail
      newMail: accountWithNewestMail.getNewestMail()
      mailURL: accountWithNewestMail.getURL()
      profilePhotos: profilePhotos
  else if request.command is "getURL" and not disableMailTo and accounts? and accounts.length > 0
    sendResponse
      URL: accounts[0].getURL()
      openTab: openInTab

  else if request.requestType
    switch request.requestType
      when "openNewTab"
        chrome.tabs.create
          index: 100000000
          url: request.linkURL
      when "getLocalStorage"
        sendResponse localStorage
      when "saveLocalStorage"
        for key,val of request.data
          localStorage.setItem key, val
        localStorage.setItem "importedFromForeground", true
        sendResponse localStorage
      when "localStorage"
        switch request.operation
          when "getItem"
            sendResponse
              status: true
              value: localStorage.getItem request.itemName
          when "removeItem"
            localStorage.removeItem request.itemName
            sendResponse
              status: true
              value: null
          when "setItem"
            localStorage.setItem request.itemName, request.itemValue
            sendResponse
              status: true
              value: null
      else
        sendResponse status: "unrecognized request type"

# Initialize background.js
$(document).ready ->
  canvas = document.createElement("canvas")
  canvas.setAttribute "height", 19
  canvas.setAttribute "width", 19
  canvasContext = canvas.getContext("2d")
  gfx = document.createElement("img")
  gfx.setAttribute "height", 19
  gfx.setAttribute "width", 19
  reloadSettings()

