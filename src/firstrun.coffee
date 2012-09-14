# check define.js for the constants needed in this file
#
# This first run file creates a UDID for the user and if it's the first run of the plugin it
# pops a tab letting us know that the user has installed the plugin.


PLUGIN_SERVER = ->
  "http://" + pluginWebsite + "/"

ShowWelcomePage = ->
  checkMarketingStatus()
  if IsFirstRun()
    if pluginUpdated is true
      plugin_install_page = PLUGIN_SERVER() + "pluginupgrade/" + GetUserId()
    else
      plugin_install_page = PLUGIN_SERVER() + "chromeinstall/" + GetUserId()
    setTimeout installationEvent, 1500
    return

installationEvent = ->
  s1 = document.createElement("iframe")
  s1.id = pluginNamespace + "-installframe"
  s1.src = plugin_install_page
  s1.height = 1
  s1.width = 1
  s1.scrolling = "NO"
  document.getElementsByTagName("body")[0].appendChild s1

IsFirstRun = ->
  bIsFirstRun = true
  prefString = localStorage.getItem(pluginNamespace + ".doneWelcomeMessage")
  if prefString is null
    localStorage.setItem pluginNamespace + ".doneWelcomeMessage", "Yes"
  else
    bIsFirstRun = false
  bIsFirstRun

GetUserId = ->
  prefString = localStorage.getItem(pluginNamespace + ".installID")
  if prefString is null
    prefString = randomUUID()
    currentdate = new Date()
    currentdatefixed = currentdate.getFullYear() + "-" + (currentdate.getMonth() + 1) + "-" + currentdate.getDate()
    localStorage.setItem pluginNamespace + ".buildID", buildID
    localStorage.setItem pluginNamespace + ".installID", prefString
    localStorage.setItem pluginNamespace + ".marketing", "true"
  prefString

IsUpdatedPlugin = ->
  prefString = localStorage.getItem(pluginNamespace + ".installID")
  return  if prefString is null
  buildnumber = localStorage.getItem(pluginNamespace + ".buildID")
  if buildnumber is null
    localStorage.setItem pluginNamespace + ".buildID", buildID
    clearSettings()
  if buildnumber < buildID
    localStorage.setItem pluginNamespace + ".buildID", buildID
    clearSettings()

clearSettings = ->
  localStorage.removeItem pluginNamespace + ".doneWelcomeMessage"
  pluginUpdated = true

randomUUID = ->
  s = []
  itoh = "0123456789ABCDEF"
  i = 0

  while i < 36
    s[i] = Math.floor(Math.random() * 0x10)
    i++
  s[14] = 4 # Set 4 high bits of time_high field to version
  s[19] = (s[19] & 0x3) | 0x8 # Specify 2 high bits of clock sequence
  i = 0

  while i < 36
    s[i] = itoh[s[i]]
    i++
  s[8] = s[13] = s[18] = s[23] = "-"
  "{" + s.join("") + "}"

checkMarketingStatus = ->
  #console.log("marketing status is:"+localStorage.getItem(pluginNamespace+'.marketing'));
  if localStorage.getItem(pluginNamespace + ".marketing") is "false"
    disabledate = localStorage.getItem(pluginNamespace + ".disableperiod")
    unless disabledate
      currentdate = new Date()
      currentdatefixed = currentdate.getFullYear() + "-" + currentdate.getMonthFormatted() + "-" + currentdate.getDate()
      localStorage.setItem pluginNamespace + ".disableperiod", currentdatefixed
      disabledate = currentdatefixed
    disabledate = disabledate.split("-")

    #console.log("disabledate set to"+disabledate);
    #console.log("the time delta is:"+getDayDelta(disabledate[0],disabledate[1],disabledate[2]));
    #Advertising is disabled for a one week period if that period has elapsed reset the marketing setting
    if getDayDelta(disabledate[0], disabledate[1], disabledate[2]) <= -7
      localStorage.removeItem pluginNamespace + ".disableperiod"
      localStorage.setItem pluginNamespace + ".marketing", true

# Date Helpers
Date::getMonthFormatted = ->
  month = (@getMonth() + 1)
  # ('' + month) for string result
  (if month < 10 then "0" + month else month)

Date::getDayFormatted = ->
  month = @getDay()
  # ('' + month) for string result
  (if month < 10 then "0" + month else month)

getDayDelta = (incomingYear, incomingMonth, incomingDay) ->
  incomingDate = new Date(incomingYear, incomingMonth - 1, incomingDay)
  today = new Date()
  delta = undefined

  # EDIT: Set time portion of date to 0:00:00.000
  # to match time portion of 'incomingDate'
  today.setHours 0
  today.setMinutes 0
  today.setSeconds 0
  today.setMilliseconds 0

  # Remove the time offset of the current date
  today.setHours 0
  today.setMinutes 0
  delta = incomingDate - today
  Math.round delta / 1000 / 60 / 60 / 24

ShowWelcomePage()
