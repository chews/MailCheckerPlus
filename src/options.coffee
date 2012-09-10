#/ <reference path="chrome-api-vsdoc.js" />
#/ <reference path="jquery-1.4.2.js" />
#/ <reference path="mailaccount.class.js" />

# Extensions to the local storage class for object storage 
sortlist = (lb) ->
  arrTexts = new Array()
  i = 0
  while i < lb.length
    arrTexts[i] = lb.options[i].text + ":" + lb.options[i].value + ":" + lb.options[i].selected
    i++
  arrTexts.sort charOrdA
  i = 0
  while i < lb.length
    el = arrTexts[i].split(":")
    lb.options[i].text = el[0]
    lb.options[i].value = el[1]
    lb.options[i].selected = (if (el[2] is "true") then true else false)
    i++
charOrdA = (a, b) ->
  a = a.toLowerCase()
  b = b.toLowerCase()
  return 1  if a > b
  return -1  if a < b
  0

# Saves options to localStorage.

#                            "check_all",
#                            "check_priority",
#"force_ssl",
save_options = ->
  for i of boolIdArray
    id = boolIdArray[i]
    element = document.getElementById(id)
    value = element.checked
    localStorage["gc_" + id] = value
    console.log "saved: " + id + " as " + value
  iconRadios = document.forms[0].icon_set
  for i of iconRadios
    if iconRadios[i].checked
      localStorage["gc_icon_set"] = iconRadios[i].value
      break
  previewRadios = document.forms[0].preview_setting
  for i of previewRadios
    if previewRadios[i].checked
      localStorage["gc_preview_setting"] = previewRadios[i].value
      break
  delete localStorage["gc_poll"]

  delete localStorage["gc_dn_timeout"]

  delete localStorage["gc_accounts"]

  if document.getElementById("enable_marketing").checked
    localStorage["mailcheckerplus.marketing"] = "true"
  else
    localStorage["mailcheckerplus.marketing"] = "false"
  localStorage["gc_poll"] = parseInt(document.getElementById("poll").value)
  localStorage["gc_dn_timeout"] = parseInt(document.getElementById("dn_timeout").value)
  localStorage["gc_language"] = document.getElementById("languages").value
  localStorage["gc_check_label"] = document.getElementById("check_label").value
  localStorage["gc_open_label"] = document.getElementById("open_label").value
  localStorage.setObject "gc_accounts", accounts  if accounts.length > 0
  localStorage["gc_sn_audio"] = document.getElementById("sn_audio").value
  if localStorage["gc_sn_audio"] is "custom"
    try
      localStorage["gc_sn_audio_raw"] = document.getElementById("sn_audio_enc").value
    catch e
      alert e
  else
    localStorage["gc_sn_audio_raw"] = null
  backgroundPage = chrome.extension.getBackgroundPage()
  backgroundPage.init()

# Restores input states to saved values from localStorage.
restore_options = ->
  showContent 0
  for i of boolIdArray
    id = boolIdArray[i]
    value = localStorage["gc_" + id]
    if value is "true"
      element = document.getElementById(id)
      element.checked = true
    console.log "restored: " + id + " as " + value
  spawnIconRow "set1", "Default"
  spawnIconRow "set2", "Default Grey"
  spawnIconRow "set3", "Default White"
  spawnIconRow "set11", "Native"
  spawnIconRow "set12", "Native Grey"
  spawnIconRow "set8", "Gmail Glossy"
  spawnIconRow "set9", "Gmail Mini"
  spawnIconRow "set10", "Gmail Monochrome"
  spawnIconRow "set4", "Alternative 1"
  spawnIconRow "set5", "Alternative 2"
  spawnIconRow "set6", "Chromified Classic"
  spawnIconRow "set7", "Chromified Grey"
  iconRadios = document.forms[0].icon_set
  iconFound = false
  for i of iconRadios
    if iconRadios[i].value is localStorage["gc_icon_set"]
      iconRadios[i].checked = true
      iconFound = true
      break
  iconRadios[0].checked = true  unless iconFound
  previewRadios = document.forms[0].preview_setting
  for i of previewRadios
    if previewRadios[i].value is localStorage["gc_preview_setting"]
      previewRadios[i].checked = true
      break
  document.getElementById("poll_" + localStorage["gc_poll"]).selected = true  if localStorage["gc_poll"]?
  document.getElementById("dn_timeout_" + localStorage["gc_dn_timeout"]).selected = true  if localStorage["gc_dn_timeout"]?
  document.getElementById("check_label_" + localStorage["gc_check_label"]).selected = true  if localStorage["gc_check_label"]?
  document.getElementById("open_label_" + localStorage["gc_open_label"]).selected = true  if localStorage["gc_open_label"]?
  if localStorage["mailcheckerplus.marketing"]?
    if localStorage["mailcheckerplus.marketing"] is "true"
      document.getElementById("enable_marketing").checked = true
    else
      document.getElementById("enable_marketing").checked = false
  else
    document.getElementById("enable_marketing").checked = true
    localStorage["mailcheckerplus.marketing"] = "true"
  accounts = localStorage.getObject("gc_accounts")
  accounts = new Array()  unless accounts?
  langSel = document.getElementById("languages")
  for i of languages
    langSel.add new Option(languages[i].what, languages[i].id), languages[i].id
  langSel.value = localStorage["gc_language"]
  sortlist langSel
  acc_sel = document.getElementById("accounts")
  for i of accounts
    break  if not accounts[i]? or not accounts[i].domain?
    acc_sel.add new Option(accounts[i].domain), null
  
  #chrome.extension.getBackgroundPage().getLabels("https://mail.google.com/mail/", loadLabels);
  $("#sn_audio").val localStorage["gc_sn_audio"]
  $("#sn_audio_enc").val localStorage["gc_sn_audio_raw"]
  $("#sn_audio").change ->
    if @value is "custom"
      $("#sn_audio_src").show()
    else
      $("#sn_audio_src").hide()

  $("#sn_audio_src").hide()  unless localStorage["gc_sn_audio"] is "custom"
loadLabels = (labels) ->
  $(labels).each (i) ->
    $("#labels")[0].add new Option(labels[i])

showContent = (contentId) ->
  $(".content").each (index) ->
    $(this).addClass "invisible"  unless $(this).hasClass("invisible")
    $(this).removeClass "invisible"  if index is contentId

  $("ul.menu > li > a").each (index) ->
    $(this).removeClass "active"
    $(this).addClass "active"  if index is contentId

spawnIconRow = (value, description) ->
  selectionElement = document.getElementById("icon_selection")
  selectionElement.innerHTML += "<span><input type=\"radio\" name=\"icon_set\" value=\"" + value + "\" id=\"icon_set" + value + "\" /><label for=\"icon_set" + value + "\"><img src=\"icons/" + value + "/not_logged_in.png\" /><img src=\"icons/" + value + "/no_new.png\" /><img src=\"icons/" + value + "/new.png\" /> <small>" + description + "</small></span></label><br />"
add_account = ->
  newacc_domain = prompt("Enter the domain name for your GAFYD account." + "\n\nDo not enter anything but the domain name!" + "\n\nIf your mail adress is <yourname@yourdomain.com>, simply enter \"yourdomain.com\"", "yourdomain.com")
  if newacc_domain? and newacc_domain isnt "" and newacc_domain isnt "yourdomain.com"
    document.getElementById("check_gmail_off").checked = "true"
    accounts.push domain: newacc_domain
    acc_sel = document.getElementById("accounts")
    acc_sel.add new Option(newacc_domain), null

#acc_sel.size = accounts.length + 1;
remove_account = ->
  acc_sel = document.getElementById("accounts")
  acc_todel = undefined
  if acc_sel.selectedIndex > -1 and acc_sel.options[acc_sel.selectedIndex]?
    acc_todel = acc_sel.options[acc_sel.selectedIndex]
    for i of accounts
      if accounts[i].domain is acc_todel.text
        console.log "removing account: " + accounts[i].domain
        accounts.splice i, 1
        break
    acc_sel.remove acc_sel.selectedIndex

#acc_sel.size = accounts.length + 1;
add_label = ->
  newlabel = prompt("Enter the name of the label." + "\n\nDo not enter anything but the label name!")
  if newlabel? and newlabel isnt "" and newlabel isnt "yourdomain.com"
    
    #accounts.push({"label":newlabel});
    labels_sel = document.getElementById("labels")
    labels_sel.add new Option(newlabel), null
    labels_sel.size = accounts.length + 1
remove_label = ->
  labels_sel = document.getElementById("labels")
  label_todel = undefined
  if labels_sel.selectedIndex > -1 and labels_sel.options[labels_sel.selectedIndex]?
    label_todel = labels_sel.options[labels_sel.selectedIndex]
    for i of accounts
      if accounts[i].domain is label_todel.text
        console.log "removing account: " + accounts[i].domain
        accounts.splice i, 1
        break
    labels_sel.remove labels_sel.selectedIndex
    labels_sel.size = accounts.length + 1
requestUserPermission = ->
  try
    checkboxUserPermission = document.getElementById("show_notification")
    if checkboxUserPermission.checked
      return  if checkUserPermission()
      unless typeof webkitNotifications is "undefined"
        webkitNotifications.requestPermission ->
          permissionGranted = checkUserPermission()
          checkboxUserPermission.checked = permissionGranted

  catch e
    checkboxUserPermission.checked = false
checkUserPermission = ->
  try
    return (webkitNotifications.checkPermission() is 0)
  catch e
    return false
toggleCheckBox = (checkboxId, checked) ->
  document.getElementById(checkboxId).checked = not checked  if checked
handleAudioFile = (fileList) ->
  file = fileList[0]
  fileReader = new FileReader()
  fileReader.onloadend = ->
    try
      localStorage["temp"] = @result
    catch e
      alert "The file you have chosen is too large, please select a shorter sound alert."
      return
    finally
      localStorage["temp"] = null
      delete localStorage["temp"]
    $("#sn_audio_enc").val @result
    $("#submit").val "Save &amp; Reload"
    $("#submit").removeAttr "disabled"

  fileReader.onabort = fileReader.onerror = ->
    switch @error.code
      when FileError.NOT_FOUND_ERR
        alert "File not found!"
      when FileError.SECURITY_ERR
        alert "Security error!"
      when FileError.NOT_READABLE_ERR
        alert "File not readable!"
      when FileError.ENCODING_ERR
        alert "Encoding error in file!"
      else
        alert "An error occured while reading the file!"
    $("#submit").val "Save &amp; Reload"
    $("#submit").removeAttr "disabled"

  $("#submit").val "Processing..."
  $("#submit").attr "disabled", "disabled"
  fileReader.readAsDataURL file
playNotificationSound = ->
  source = undefined
  if document.getElementById("sn_audio").value is "custom"
    if document.getElementById("sn_audio_enc").value
      source = document.getElementById("sn_audio_enc").value
    else
      source = localStorage["gc_sn_audio_raw"]
  else
    source = document.getElementById("sn_audio").value
  try
    audioElement = new Audio()
    audioElement.src = source
    audioElement.play()
  catch e
    console.error e
Storage::setObject = (key, value) ->
  @setItem key, JSON.stringify(value)

Storage::getObject = (key) ->
  @getItem(key) and JSON.parse(@getItem(key))

boolIdArray = new Array("hide_count", "showfull_read", "check_gmail_off", "open_tabs", "archive_read", "no_mailto", "sound_off", "animate_off", "show_notification")
accounts = undefined
$(document).ready ->
  
  # Initialize options.html page.
  restore_options()
  
  # Play notification sound
  $("#play-sound").click ->
    playNotificationSound()

  
  # Save options.
  $("#submit").click ->
    save_options()
    false

  
  # Handle file upload.
  $("#sn_audio_src").change ->
    handleAudioFile @files

  
  # Menu event handlers
  $("#showContent0").click ->
    showContent 0

  $("#showContent1").click ->
    showContent 1

  $("#showContent2").click ->
    showContent 2

  $("#showContent3").click ->
    showContent 3

  $("#showContent4").click ->
    showContent 4

  $("#add_account").click ->
    add_account()

  $("#remove_account").click ->
    remove_account()


