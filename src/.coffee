#/ <reference path="jquery-1.4.2.js" />
#/ <reference path="chrome-api-vsdoc.js" />
#/ <reference path="encoder.js" />

#var mailArray = mailAccount.getMail();

# Preview setting set to "Always off" =
# Go to first mail inbox with unread items

# Preview setting set to "Automatic" + no unread mail =
# Go to first mail inbox
hideElement = (id) ->
  element = document.getElementById(id)
  element.style.display = "none"  if element?
showElement = (id) ->
  element = document.getElementById(id)
  element.style.display = "inline"  if element?

# Opens a mail and closes this window
openMail = (accountId, mailid) ->
  mailAccounts[accountId].openThread mailid

#window.close();
openInbox = (accountId) ->
  unless accountId?
    accountId = 0
    
    # Open first inbox with unread items
    $.each mailAccounts, (i, account) ->
      if account.getUnreadCount() > 0
        accountId = account.id
        false

  if not mailAccounts? or not mailAccounts[accountId]?
    console.error "No mailaccount(s) found with account id " + accountId
    return
  mailAccounts[accountId].openInbox()
  window.close()

#function openUnread(accountId) {
#   mailAccounts[accountId].openUnread();
#   window.close();
#}
composeNew = (accountId) ->
  mailAccounts[accountId].composeNew()
  window.close()
sendPage = (accountId) ->
  chrome.tabs.getSelected null, (tab) ->
    mailAccounts[accountId].sendPage tab
    window.close()

readThread = (accountId, mailid, stayOpen) ->
  hideMail accountId, mailid, stayOpen
  mailAccounts[accountId].readThread mailid
unreadThread = (accountId, mailid) ->
  mailAccounts[accountId].unreadThread mailid
  mailElement = document.getElementById(mailid)
  if mailElement?
    mailHeaderReadLink = document.getElementById(mailid + "_read-link")
    if mailHeaderReadLink?
      mailHeaderReadLink.href = "javascript:readThread('" + accountId + "', '" + mailid + "');"
      mailHeaderReadLink.innerHTML = i18n.get("readLink")
      mailHeaderReadLink.title = i18n.get("readLinkTitle")
archiveThread = (accountId, mailid) ->
  hideMail accountId, mailid
  mailAccounts[accountId].archiveThread mailid
deleteThread = (accountId, mailid) ->
  hideMail accountId, mailid
  mailAccounts[accountId].deleteThread mailid
spamThread = (accountId, mailid) ->
  hideMail accountId, mailid
  mailAccounts[accountId].spamThread mailid
starThread = (accountId, mailid) ->
  mailAccounts[accountId].starThread mailid
replyTo = (accountId, mailid) ->
  mailAccounts[accountId].replyTo allMail[mailid]
showReply = (mailid) ->
  replyBox = document.getElementById(mailid + "_reply")

#replyBox.style.display = 'block';
hideReply = (mailid) ->
  replyBox = document.getElementById(mailid + "_reply")

#replyBox.style.display = 'none';
sendReply = (mailid) ->
  replyTextArea = document.getElementById(mailid + "_replytext")
  replyText = replyTextArea.value
  hideReply mailid
  mailAccount.replyToThread
    id: mailid
    body: replyText

getThread = (accountId, mailid) ->
  markAsRead = (localStorage["gc_showfull_read"]? and localStorage["gc_showfull_read"] is "true")
  readThread accountId, mailid, true  if markAsRead
  if mailCache[mailid]?
    
    # Mail already fetched, read from cache instead
    showBody accountId, mailid, mailCache[mailid]
    return false
  window.setTimeout mailAccounts[accountId].getThread(accountId, mailid, showBody), 0  if accountId?

#
#		var mailElement = document.getElementById(mailid);
#		if(mailElement != null) {
#			var mailHeaderReadLink = document.getElementById(mailid + "_read-link");
#			if(mailHeaderReadLink != null) {
#				mailHeaderReadLink.href = "javascript:unreadThread('" + accountId + "', '" + mailid + "');";
#				mailHeaderReadLink.innerHTML = i18n.get('unreadLink');
#				mailHeaderReadLink.title = i18n.get('unreadLinkTitle');
#			}
#		}
showBody = (accountid, mailid, mailbody) ->
  
  #   showElement(mailid + "_less-link");
  #   hideElement(mailid + "_more-link");
  if mailbody?
    mail = allMail[mailid]
    fullscreenContainer = $("#fullscreenContainer")
    fullscreenContent = $("#fullscreenContent")
    fullscreenControl = $("#fullscreenControls")
    fullscreenControl.find(".openLink").html mail.shortTitle
    fullscreenControl.find(".openLink").attr "title", Encoder.htmlDecode(mail.title)
    fullscreenControl.find(".authorLink").html mail.authorName
    fullscreenControl.find(".authorLink").attr "title", Encoder.htmlDecode(mail.authorMail)
    fullscreenControl.find(".issuedLink").html formatDateTime(mail.issued, i18n.selected_lang.months, true)
    fullscreenControl.find(".issuedLink").attr "title", mail.issued
    fullscreenControl.find(".readLink").text i18n.get("readLink")
    fullscreenControl.find(".deleteLink").text i18n.get("deleteLink")
    fullscreenControl.find(".spamLink").text i18n.get("spamLink")
    fullscreenControl.find(".archiveLink").text i18n.get("archiveLink")
    fullscreenControl.find(".starLink").attr "title", i18n.get("starLinkTitle")
    fullscreenControl.find(".replyLink").attr "title", i18n.get("replyLinkTitle")
    fullscreenControl.find(".readLink").attr "title", i18n.get("readLinkTitle")
    fullscreenControl.find(".deleteLink").attr "title", i18n.get("deleteLinkTitle")
    fullscreenControl.find(".spamLink").attr "title", i18n.get("spamLinkTitle")
    fullscreenControl.find(".archiveLink").attr "title", i18n.get("archiveLinkTitle")
    
    # Insert the full mail body and full screen controls
    fullscreenContent.empty()
    fullscreenContent.html mailbody
    fullscreenContainer.empty()
    fullscreenContainer.append fullscreenControl
    fullscreenContainer.append fullscreenContent
    
    # Set event handlers
    fullscreenControl.find(".closeLink").click ->
      setTimeout hideBody(), 0

    fullscreenControl.find(".readLink").click ->
      readThread accountid, mailid
      setTimeout hideBody(), 0

    fullscreenControl.find(".replyLink").click ->
      replyTo accountid, mailid
      setTimeout hideBody(), 0

    fullscreenControl.find(".deleteLink").click ->
      deleteThread accountid, mailid
      setTimeout hideBody(), 0

    fullscreenControl.find(".spamLink").click ->
      spamThread accountid, mailid
      setTimeout hideBody(), 0

    fullscreenControl.find(".archiveLink").click ->
      archiveThread accountid, mailid
      setTimeout hideBody(), 0

    fullscreenControl.find(".openLink").click ->
      openMail accountid, mailid
      setTimeout hideBody(), 0

    fullscreenControl.find(".starLink").click ->
      $(this).css "opacity", "1"
      starThread accountid, mailid

    
    # Display full screen container
    fullscreenContainer.css "display", "block"
    
    # Save this mail in the cache
    mailCache[mailid] = mailbody
    
    # Toggle the size of the window
    expandWindow()
hideBody = ->
  
  #   var mailSummaryElement = $('#' + mailid + "_summary");
  #   var mail = allMail[mailid];
  
  #   //hideElement(mailid + "_reply-link");
  #   hideElement(mailid + "_less-link");
  #   showElement(mailid + "_more-link");
  
  # Hide full screen
  $("#fullscreenContainer").css "display", "none"
  
  # Toggle the size of the window
  contractWindow()

# Hides a mail in the mailbox
hideMail = (accountId, mailid, stayOpen) ->
  accountElement = $("#inbox_" + accountId)
  
  #   $('#' + mailid).slideUp('fast');
  #   $('#' + mailid).removeClass('mail');
  $("#" + mailid).remove()
  unreadCount = accountElement.find(".mail").length
  if unreadCount is 0
    accountElement.find(".toggleLink").hide "fast"
    accountElement.find(".unreadCount").fadeOut "fast"
    window.close()  unless stayOpen
  else
    accountElement.find(".unreadCount").text "(" + unreadCount + ")"

# Shows a hidden mail in the mailbox
showMail = (mailid) ->
  mailElement = document.getElementById(mailid)
  mailElement.style.display = "block"  if mailElement?
replyTextKeyPress = (event, mailid) ->
  
  # User pressed shift-enter inside textarea
  sendReply mailid  if event.shiftKey is 1 and event.keyCode is 13
refreshMail = ->
  $.each mailAccounts, (i, account) ->
    account.refreshInbox ->
      renderAccount account


openOptions = ->
  chrome.tabs.create url: "options.html"
resizeWindow = ->
  isExpanded = $("html").width() isnt 500
  if isExpanded
    contractWindow()
  else
    expandWindow()
expandWindow = ->
  previousHeight = $("body").height()
  $("html").animate
    width: [750, "swing"]
  
  #height: [500, 'swing']
  , animationSpeed
  $(".account").slideUp()
contractWindow = ->
  $("html").animate
    width: [500, "swing"]
  
  #height: [previousHeight, 'swing']
  , animationSpeed
  $(".account").slideDown()
  previousHeight = 0
renderMail = ->
  
  # Clear previous content
  $("#content").empty()
  
  # Loop through each account and render it on the page
  $.each mailAccounts, (i, account) ->
    account.id = i
    renderAccount account

  
  # Add event handlers
  $(".inboxLink").click ->
    openInbox $(this).attr("accountId")

  $(".composeLink").click ->
    composeNew $(this).attr("accountId")

  $(".sendpageLink").click ->
    sendPage $(this).attr("accountId")

renderAccount = (account) ->
  $("#content_" + account.id).remove()
  account.getNewAt()
  
  # Render account
  account.unreadCount = account.getMail().length  if account.getMail()?
  accountHtml = accountTemplate(account, i18n)
  
  # Add to page
  $(accountHtml).fadeIn("fast").appendTo "#content"
  inboxElement = $("#inbox_" + account.id)
  if account.getMail()?
    $.each account.getMail(), (j, mail) ->
      allMail[mail.id] = mail
      
      # Render mail
      mailHtml = mailTemplate(mail, i18n)
      
      # Add to account element
      $(mailHtml).fadeIn("fast").appendTo inboxElement

    inboxElement.find(".toggleLink").hide()  if account.getMail().length is 0
    inboxElement.find(".toggleLink").click ->
      inboxElement.find(".mail").slideToggle "fast"
      if $(this).find("img").attr("src") is "img/arrow_right.png"
        $(this).find("img").attr "src", "img/arrow_down.png"
      else
        $(this).find("img").attr "src", "img/arrow_right.png"

  
  # Hook up event handlers
  inboxElement.find(".readLink").click ->
    readThread account.id, $(this).attr("mailId")

  inboxElement.find(".deleteLink").click ->
    deleteThread account.id, $(this).attr("mailId")

  inboxElement.find(".spamLink").click ->
    spamThread account.id, $(this).attr("mailId")

  inboxElement.find(".archiveLink").click ->
    archiveThread account.id, $(this).attr("mailId")

  inboxElement.find(".fullLink").click ->
    getThread account.id, $(this).attr("mailId")

  inboxElement.find(".summary").click ->
    getThread account.id, $(this).attr("mailId")

  inboxElement.find(".replyLink").click ->
    replyTo account.id, $(this).attr("mailId")

  inboxElement.find(".openLink").click ->
    openMail account.id, $(this).attr("mailId")

  inboxElement.find(".starLink").click ->
    $(this).css "opacity", "1"
    starThread account.id, $(this).attr("mailId")

backgroundPage = chrome.extension.getBackgroundPage()
mailAccounts = backgroundPage.accounts
mailCount = 0
mailCache = new Array()
allMail = undefined
scrollbar = undefined
unreadCount = 0
allMail = new Array()
$.each mailAccounts, (i, account) ->
  unreadCount += account.getUnreadCount()

previewSetting = localStorage["gc_preview_setting"]
if previewSetting is "0"
  openInbox 0
else openInbox 0  if previewSetting is "1" and unreadCount is 0
animationSpeed = 250
previousHeight = undefined
$(document).ready ->
  unreadCount = 0
  allMail = new Array()
  $.each mailAccounts, (i, account) ->
    unreadCount += account.getUnreadCount()

  backgroundPage.stopAnimateLoop()
  renderMail()
  
  # Should probably use jQuery for this
  document.getElementById("refresh").setAttribute "title", i18n.get("refreshLinkTitle")
  document.getElementById("options").setAttribute "title", i18n.get("optionsLinkTitle")

