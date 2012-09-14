mailAccount = undefined

# Opens a mail and closes this window
openMail = ->
  window.close()
  mailAccount.openNewestMail()

# Marks mail as read and closes this window
readMail = ->
  window.close()
  mailAccount.readNewestMail()

# Deletes mail and closes this window
deleteMail = ->
  window.close()
  mailAccount.deleteNewestMail()

# Marks mail as spam and closes this window
spamMail = ->
  window.close()
  mailAccount.spamNewestMail()

# Archives mail and closes this window
archiveMail = ->
  window.close()
  mailAccount.archiveNewestMail()

# Star mail
starMail = ->
  mailAccount.starNewestMail()

# Star mail
openInbox = ->
  mailAccount.openInbox()

$(document).ready ->
  backgroundPage = chrome.extension.getBackgroundPage()
  mailAccount = backgroundPage.accountWithNewestMail
  mailAccount.id = backgroundPage.accounts.indexOf(mailAccount)
  mail = backgroundPage.accountWithNewestMail.getNewestMail()
  mailURL = backgroundPage.accountWithNewestMail.getURL()
  profilePhotos = backgroundPage.profilePhotos
  fullDateTime = mail.issued.toLocaleString()
  datetime = formatDateTime(mail.issued, i18n.selected_lang.months)
  mailHtml = notifyTemplate(mailAccount, datetime, i18n, mail)

  $("body").append mailHtml

  $("body").hover (->
    $(this).find(".hiddenSummaryActions").fadeIn "fast"
  ), ->
    $(this).find(".hiddenSummaryActions").fadeOut "fast"

  $("body").find(".readLink").click ->
    readMail()

  $("body").find(".deleteLink").click ->
    deleteMail()

  $("body").find(".spamLink").click ->
    spamMail()

  $("body").find(".archiveLink").click ->
    archiveMail()

  $("body").find(".openLink").click ->
    openMail()

  $("body").find(".inboxLink").click ->
    openInbox()

  $("body").find(".starLink").click ->
    $(this).css "opacity", "1"
    starMail()
