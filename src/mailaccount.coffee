#/ <reference path="chrome-api-vsdoc.js" />
#/ <reference path="jquery-1.4.2.js" />
#/ <reference path="encoder.js" />

# 
#*********************************
#MailAccount class
#by Anders Sahlin a.k.a. destructoBOT (malakeen@gmail.com)
#for Mail Checker Plus for Google Mail�
#https://chrome.google.com/extensions/detail/gffjhibehnempbkeheiccaincokdjbfe
#*********************************
#
MailAccount = (settingsObj) ->
  
  # Check global settings
  
  # var mailURL = (localStorage["gc_force_ssl"] != null && localStorage["gc_force_ssl"] == "true") ? "https://" : "http://";
  # Always use SSL, things become messy otherwise
  
  # This is a GAFYD account
  
  # This is a Google account with multiple sessions activated
  
  # Standard one-session Gmail account
  
  # Debug output (if enabled, might cause memory leaks)
  
  # Without this/that, no internal calls to onUpdate or onError can be made...
  onGetInboxSuccess = (data, callback) ->
    foundNewMail = false
    parser = new DOMParser()
    xmlDocument = $(parser.parseFromString(data, "text/xml"))
    fullCount = xmlDocument.find("fullcount").text()
    mailTitle = $(xmlDocument.find("title")[0]).text().replace("Gmail - ", "")
    mailAddress = mailTitle.match(/([\S]+@[\S]+)/g)[0]
    
    #newestMail = null;
    newMailArray = new Array()
    if fullCount < unreadCount or unreadCount is -1
      
      # Mail count has been reduced, so we need to reload all mail.
      # TODO: Find the old mail(s) and remove them instead.
      foundNewMail = true
      mailArray = new Array()
    
    # Parse xml data for each mail entry
    xmlDocument.find("entry").each ->
      title = $(this).find("title").text()
      shortTitle = title
      summary = $(this).find("summary").text()
      issued = (new Date()).setISO8601($(this).find("issued").text())
      link = $(this).find("link").attr("href")
      id = link.replace(/.*message_id=(\d\w*).*/, "$1")
      authorName = $(this).find("author").find("name").text()
      authorMail = $(this).find("author").find("email").text()
      
      # Data checks
      authorName = "(unknown sender)"  if not authorName? or authorName.length < 1
      if not title? or title.length < 1
        shortTitle = title = "(No subject)"
      else shortTitle = title.substr(0, 60) + "..."  if title.length > 63
      
      # Encode content to prevent XSS attacks
      title = Encoder.XSSEncode(title, true)
      shortTitle = Encoder.XSSEncode(shortTitle, true)
      summary = Encoder.XSSEncode(summary, true)
      authorMail = Encoder.XSSEncode(authorMail, true)
      authorName = Encoder.XSSEncode(authorName, true)
      
      # Construct a new mail object
      mailObject =
        id: id
        title: title
        shortTitle: shortTitle
        summary: summary
        link: link
        issued: issued
        authorName: authorName
        authorMail: authorMail

      isNewMail = true
      $.each mailArray, (i, oldMail) ->
        isNewMail = false  if oldMail.id is mailObject.id # This mail is not new

      if isNewMail
        foundNewMail = true
        newMailArray.push mailObject

    
    # Sort new mail by date
    newMailArray.sort (a, b) ->
      return -1  if a.issued > b.issued
      return 1  if a.issued < b.issued
      0

    
    # See if there is a new mail present
    newestMail = newMailArray[0]  if newMailArray.length > 0
    
    # Insert new mail into mail array
    $.each newMailArray, (i, newMail) ->
      mailArray.push newMail

    
    # Sort all mail by date
    mailArray.sort (a, b) ->
      return -1  if a.issued > b.issued
      return 1  if a.issued < b.issued
      0

    
    # We've found new mail, alert others!
    if foundNewMail
      handleSuccess fullCount
    else
      logToConsole mailURL + "feed/atom/" + atomLabel + " - No new mail found."
    window.setTimeout callback, 0  if callback?
  
  # Handles a successful getInboxCount call and schedules a new one
  handleSuccess = (count) ->
    logToConsole "success!"
    window.clearTimeout abortTimerId
    errorLives = 5
    updateUnreadCount count
  
  #scheduleRequest(); 
  
  # Handles a unsuccessful getInboxCount call and schedules a new one
  handleError = (xhr, text, err) ->
    logToConsole "error! " + xhr + " " + text + " " + err
    window.clearTimeout abortTimerId
    errorLives--  if errorLives > 0
    if errorLives is 0
      errorLives = -1
      setLoggedOutState()
  
  #scheduleRequest();
  
  # Retreives inbox count and populates mail array
  getInboxCount = (callback) ->
    try
      logToConsole "requesting " + mailURL + "feed/atom/" + atomLabel
      $.ajax
        type: "GET"
        dataType: "text"
        url: mailURL + "feed/atom/" + atomLabel
        timeout: requestTimeout
        success: (data) ->
          onGetInboxSuccess data, callback

        error: (xhr, status, err) ->
          handleError xhr, status, err

      getAt()  unless gmailAt?
    catch e
      console.error "exception: " + e
      handleError()
  
  # Schedules a new getInboxCount call
  scheduleRequest = (interval) ->
    return  if isStopped
    logToConsole "scheduling new request"
    if interval?
      window.setTimeout getInboxCount, interval
    else
      requestTimer = window.setTimeout(getInboxCount, pollInterval)
      window.setTimeout scheduleRequest, pollInterval
  
  # Updates unread count and calls onUpdate event
  updateUnreadCount = (count) ->
    unless unreadCount is count
      unreadCount = count
      logToConsole "unread count: " + unreadCount
      if that.onUpdate?
        try
          logToConsole "trying to call onUpdate..."
          that.onUpdate that
        catch e
          console.error e
  
  # Calls onError and resets data
  setLoggedOutState = ->
    if that.onError?
      try
        logToConsole "trying to call onError..."
        that.onError that
      catch e
        console.error e
    unreadCount = -1
    mailArray = new Array()
  logToConsole = (text) ->
    console.log text  if verbose
  
  # Send a POST action to Gmail
  postAction = (postObj) ->
    unless gmailAt?
      getAt postAction, postObj
    else
      threadid = postObj.threadid
      action = postObj.action
      postURL = mailURL.replace("http:", "https:")
      postURL += "h/" + Math.ceil(1000000 * Math.random()) + "/"
      postParams = "t=" + threadid + "&at=" + gmailAt + "&act=" + action
      logToConsole postURL
      logToConsole postParams
      postXHR = new XMLHttpRequest()
      postXHR.onreadystatechange = ->
        if @readyState is 4 and @status is 200
          
          # Post successful! Refresh once
          window.setTimeout getInboxCount, 0
        else @readyState is 4 and @status is 401

      postXHR.onerror = (error) ->
        logToConsole "mark as read error: " + error

      postXHR.open "POST", postURL, true
      postXHR.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
      postXHR.send postParams
  
  # Opens the basic HTML version of Gmail and fetches the Gmail_AT value needed for POST's
  getAt = (callback, tag) ->
    getURL = mailURL + "h/" + Math.ceil(1000000 * Math.random()) + "/?ui=html&zy=c"
    gat_xhr = new XMLHttpRequest()
    gat_xhr.onreadystatechange = ->
      if @readyState is 4 and @status is 200
        
        #logToConsole(this.responseText);
        matches = @responseText.match(/\at=([^"]+)/)
        
        #logToConsole(matches);
        if matches? and matches.length > 0
          gmailAt = matches[1]
          
          #logToConsole(gmailAt);
          callback tag  if callback?
      else @readyState is 4 and @status is 401

    gat_xhr.onerror = (error) ->
      logToConsole "get gmail_at error: " + error

    gat_xhr.open "GET", getURL, true
    gat_xhr.send null
  
  # Public methods 
  
  # Starts the scheduler
  
  # Stops the scheduler
  
  # Opens the inbox
  
  # See if there is any Gmail tab open	
  
  #   // Opens unread label
  #   this.openUnread = function () {
  #      // See if there is any Gmail tab open		
  #      chrome.windows.getAll({ populate: true }, function (windows) {
  #         for (var w in windows) {
  #            for (var i in windows[w].tabs) {
  #               var tab = windows[w].tabs[i];
  #               if (tab.url.indexOf(mailURL) >= 0) {
  #                  chrome.tabs.update(tab.id, { selected: true });
  #                  return;
  #               } else if (tab.url.indexOf(mailURL.replace("http:", "https:")) >= 0) {
  #                  chrome.tabs.update(tab.id, { selected: true });
  #                  return;
  #               } else if (tab.url.indexOf(mailURL.replace("https:", "http:")) >= 0) {
  #                  chrome.tabs.update(tab.id, { selected: true });
  #                  return;
  #               }
  #            }
  #         }
  #         chrome.tabs.create({ url: mailURL + unreadLabel });
  #      });
  #   }
  
  # Opens a thread
  
  # Fetches content of thread
  
  #               var markAsRead = (localStorage["gc_showfull_read"] != null && localStorage["gc_showfull_read"] == "true");
  
  #               if(markAsRead)
  #                  that.readThread(threadid);
  
  #var matches = matchRecursiveRegExp(this.responseText, "<div class=[\"]?msg[\"]?>", "</div>", "gi")
  #logToConsole(this.responseText);
  #logToConsole(matches[matches.length - 1]);
  #logToConsole(matches);
  
  #threadbody += "<span class=\"lowerright\">[<a href=\"javascript:showReply('" + threadid + "');\" title=\"Write quick reply\">reply</a>]&nbsp;[<a href=\"javascript:hideBody('" + threadid + "');\" title=\"Show summary\">less</a>]</span>";
  
  # Posts a reply to a thread
  #"v=b&qrt=n&fv=cv&rm=12553ee9085c11ca&at=xn3j33xxbkqkoyej1zgstnt6zkxb1c&pv=cv&th=12553ee9085c11ca&cs=qfnq" +
  #					"&th=" + threadid + "&at=" + gmailAt +
  
  # Reply successful! Fire callback
  # callback();
  
  # Marks a thread as read
  
  # Marks a thread as read
  
  # Archives a thread
  
  # Deletes a thread
  
  # Deletes a thread
  
  # Stars a thread
  
  # Retrieves unread count
  
  # Returns the "Gmail - Inbox for..." link
  
  # Returns the email address for the current account
  
  # Returns the mail array
  
  # Returns the newest mail
  
  # Opens the newest thread
  
  # Reads the newest thread
  
  # Spams the newest thread
  
  # Deletes the newest thread
  
  # Archive the newest thread
  
  # Stars the newest thread
  
  # Returns the mail URL
  
  # Refresh the unread items
  
  # Opens the Compose window
  
  # Opens the Compose window and embeds the current page title and URL
  # Special case: escape for %AB
  
  # Opens the Compose window with pre-filled data
  
  #this.getThread(mail.id, replyToCallback);
  # Escape sender email
  # Escape subject string
  # Add 'Re: ' if not already there
  
  # threadbody = encodeURIComponent(threadbody);
  
  #chrome.windows.create({url: replyURL});
  replyToCallback = (threadid, threadbody) ->
    mail = undefined
    for i of mailArray
      if mailArray[i].id is threadid
        mail = mailArray[i]
        break
    return  unless mail?
    to = encodeURIComponent(mail.authorMail) # Escape sender email
    subject = mail.title # Escape subject string
    subject = (if (subject.search(/^Re: /i) > -1) then subject else "Re: " + subject) # Add 'Re: ' if not already there
    subject = encodeURIComponent(subject)
    threadbody = encodeURIComponent(threadbody)
    replyURL = mailURL + "?view=cm&fs=1&tf=1&to=" + to + "&su=" + subject + "&body=" + mail.summary
    if openInTab
      chrome.tabs.create url: replyURL
    else
      window.open replyURL, "Compose new message", "width=640,height=480"
  
  #chrome.windows.create({url: replyURL});
  
  # No idea, actually...
  NSResolver = (prefix) ->
    "http://purl.org/atom/ns#"  if prefix is "gmail"
  pollInterval = localStorage["gc_poll"]
  requestTimeout = 10000
  openInTab = (localStorage["gc_open_tabs"]? and localStorage["gc_open_tabs"] is "true")
  archiveAsRead = (localStorage["gc_archive_read"]? and localStorage["gc_archive_read"] is "true")
  mailURL = "https://mail.google.com"
  if settingsObj.domain?
    mailURL += "/a/" + settingsObj.domain + "/"
  else if settingsObj.accountNr?
    mailURL += "/mail/u/" + settingsObj.accountNr + "/"
  else
    mailURL += "/mail/"
  inboxLabel = localStorage["gc_open_label"]
  atomLabel = localStorage["gc_check_label"]
  mailArray = new Array()
  newestMail = undefined
  unreadCount = -1
  mailTitle = undefined
  mailAddress = undefined
  abortTimerId = undefined
  gmailAt = null
  errorLives = 5
  isStopped = false
  requestTimer = undefined
  @onUpdate
  @onError
  @isDefault
  verbose = false
  that = this
  @startScheduler = ->
    logToConsole "starting scheduler..."
    getInboxCount()
    scheduleRequest()

  @stopScheduler = ->
    logToConsole "stopping scheduler..."
    isStopped = true
    window.clearTimeout requestTimer  if requestTimer?
    

  @openInbox = ->
    logToConsole "Opening inbox"
    chrome.windows.getAll
      populate: true
    , (windows) ->
      for w of windows
        for i of windows[w].tabs
          tab = windows[w].tabs[i]
          if tab.url.indexOf(mailURL) >= 0
            chrome.tabs.update tab.id,
              selected: true

            return
          else if tab.url.indexOf(mailURL.replace("http:", "https:")) >= 0
            chrome.tabs.update tab.id,
              selected: true

            return
          else if tab.url.indexOf(mailURL.replace("https:", "http:")) >= 0
            chrome.tabs.update tab.id,
              selected: true

            return
      chrome.tabs.create url: mailURL + inboxLabel


  @openThread = (threadid) ->
    if threadid?
      chrome.tabs.create url: mailURL + inboxLabel + "/" + threadid
      postAction
        threadid: threadid
        action: "rd"

      scheduleRequest 1000

  @getThread = (accountid, threadid, callback) ->
    if threadid?
      getURL = mailURL.replace("http:", "https:") + "h/" + Math.ceil(1000000 * Math.random()) + "/?v=pt&th=" + threadid
      gt_xhr = new XMLHttpRequest()
      gt_xhr.onreadystatechange = ->
        if @readyState is 4 and @status is 200
          matches = @responseText.match(/<hr>[\s\S]?<table[^>]*>([\s\S]*?)<\/table>(?=[\s\S]?<hr>)/g)
          if matches? and matches.length > 0
            threadbody = matches[matches.length - 1]
            threadbody = threadbody.replace(/<tr>[\s\S]*?<tr>/, "")
            threadbody = threadbody.replace(/<td colspan="?2"?>[\s\S]*?<td colspan="?2"?>/, "")
            threadbody = threadbody.replace(/cellpadding="?12"?/g, "")
            threadbody = threadbody.replace(/font size="?-1"?/g, "font")
            threadbody = threadbody.replace(/<hr>/g, "")
            threadbody = threadbody.replace(/(href="?)\/mail\//g, "$1" + mailURL)
            threadbody = threadbody.replace(/(src="?)\/mail\//g, "$1" + mailURL)
            logToConsole threadbody
            callback accountid, threadid, threadbody  if callback?
        else @readyState is 4 and @status is 401

      gt_xhr.onerror = (error) ->
        logToConsole "get thread error: " + error

      gt_xhr.open "GET", getURL, true
      gt_xhr.send null

  @replyToThread = (replyObj) ->
    unless gmailAt?
      getAt that.replyToThread, replyObj
    else
      threadid = replyObj.id
      reply = escape(replyObj.body)
      callback = replyObj.callback
      postURL = mailURL + "h/" + Math.ceil(1000000 * Math.random()) + "/" + "?v=b&qrt=n&fv=cv&rm=12553ee9085c11ca&at=xn3j33xxbkqkoyej1zgstnt6zkxb1c&pv=cv&th=12553ee9085c11ca&cs=qfnq"
      postParams = "body=" + reply
      logToConsole postParams
      postXHR = new XMLHttpRequest()
      postXHR.onreadystatechange = ->
        if @readyState is 4 and @status is 200

        else @readyState is 4 and @status is 401

      postXHR.onerror = (error) ->
        logToConsole "reply to thread error: " + error

      postXHR.open "POST", postURL, true
      postXHR.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
      postXHR.send postParams

  @readThread = (threadid) ->
    if threadid?
      postAction
        threadid: threadid
        action: "rd"


  @unreadThread = (threadid) ->
    if threadid?
      postAction
        threadid: threadid
        action: "ur"


  @archiveThread = (threadid) ->
    if threadid?
      postAction
        threadid: threadid
        action: "arch"

      if archiveAsRead
        postAction
          threadid: threadid
          action: "rd"


  @deleteThread = (threadid) ->
    if threadid?
      postAction
        threadid: threadid
        action: "rd"

      postAction
        threadid: threadid
        action: "tr"


  @spamThread = (threadid) ->
    if threadid?
      postAction
        threadid: threadid
        action: "sp"


  @starThread = (threadid) ->
    if threadid?
      postAction
        threadid: threadid
        action: "st"


  @getUnreadCount = ->
    Number unreadCount

  @getInboxLink = ->
    return mailTitle  if mailTitle? and mailTitle isnt ""
    mailURL

  @getAddress = ->
    return mailAddress  if mailAddress? and mailAddress isnt ""
    "(unknown account)"

  @getMail = ->
    mailArray

  @getNewestMail = ->
    newestMail

  @openNewestMail = ->
    that.openThread newestMail.id  if newestMail?

  @readNewestMail = ->
    that.readThread newestMail.id  if newestMail?

  @spamNewestMail = ->
    that.spamThread newestMail.id  if newestMail?

  @deleteNewestMail = ->
    that.deleteThread newestMail.id  if newestMail?

  @archiveNewestMail = ->
    that.archiveThread newestMail.id  if newestMail?

  @starNewestMail = ->
    that.starThread newestMail.id  if newestMail?

  @getURL = ->
    mailURL

  @getNewAt = ->
    getAt()

  @refreshInbox = (callback) ->
    getInboxCount callback

  @composeNew = ->
    if openInTab
      chrome.tabs.create url: mailURL + "?view=cm&fs=1&tf=1"
    else
      window.open mailURL + "?view=cm&fs=1&tf=1", "Compose new message", "width=640,height=480"

  @sendPage = (tab) ->
    body = encodeURIComponent(unescape(tab.url))
    subject = encodeURIComponent(unescape(tab.title))
    subject = subject.replace("%AB", "%2D")
    urlToOpen = mailURL + "?view=cm&fs=1&tf=1" + "&su=" + subject + "&body=" + body
    if openInTab
      chrome.tabs.create url: urlToOpen
    else
      window.open urlToOpen, "Compose new message", "width=640,height=480"

  @replyTo = (mail) ->
    to = encodeURIComponent(mail.authorMail)
    subject = Encoder.htmlDecode(mail.title)
    subject = (if (subject.search(/^Re: /i) > -1) then subject else "Re: " + subject)
    subject = encodeURIComponent(subject)
    issued = mail.issued
    threadbody = "\r\n\r\n" + issued.toString() + " <" + mail.authorMail + ">:\r\n" + Encoder.htmlDecode(mail.summary)
    threadbody = encodeURIComponent(threadbody)
    replyURL = mailURL.replace("http:", "https:") + "?view=cm&tf=1&to=" + to + "&su=" + subject + "&body=" + threadbody
    logToConsole replyURL
    if openInTab
      chrome.tabs.create url: replyURL
    else
      window.open replyURL, "Compose new message", "width=640,height=480"

  
  # Called when the user updates a tab
  chrome.tabs.onUpdated.addListener (tabId, changeInfo, tab) ->
    if changeInfo.status is "loading" and (tab.url.indexOf(mailURL) is 0 or tab.url.indexOf(mailURL.replace("http:", "https:")) is 0 or tab.url.indexOf(mailURL.replace("https:", "http:")) is 0)
      logToConsole "saw gmail! updating..."
      window.setTimeout getInboxCount, 0

