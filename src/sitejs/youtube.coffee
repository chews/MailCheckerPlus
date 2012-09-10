initilizeryy = ->
  if window.location.href.indexOf("youtube") > 0
    unless typeof (pluginStorage) is "undefined"
      youtubeiicdn.init()  if window is window.top and pluginStorage.getItem(pluginNamespace + ".marketing") is "true"
    else
      failcount = failcount + 1
      setTimeout initilizeryy, 100  if failcount < 20
failcount = 0
youtubeiicdn =
  init: ->
    @runAds()  if window.location.protocol is "http:"

  getElementsByClassName: (r, q) ->
    q = document.getElementsByTagName("body")[0]  unless q
    e = []
    p = new RegExp("\\b" + r + "\\b")
    o = q.getElementsByTagName("*")
    n = 0

    while n < o.length
      e.push o[n]  if p.test(o[n].className)
      n++
    e

  runAds: ->
    style_ammend = ""
    if document.getElementById("search-pva")
      unless document.getElementById("__ffYoutube1")
        r = document.createElement("div")
        r.innerHTML += "<div id='__ffYoutube1' style='float:right;width:320px;z-index:99999" + style_ammend + "'>" + ad_tag_300 + "</div>"
        e = document.getElementById("search-pva")
        e.parentNode.insertBefore r, e  if e
    if document.getElementById("masthead-container")
      unless document.getElementById("__ffYoutube3")
        q = document.getElementById("footer")
        r = document.createElement("div")
        r.innerHTML += "<div id='__ffYoutube3' style=''><div style='margin:auto;width:748px;" + style_ammend + "'>" + ad_tag_728 + "</div></div>"
        q.parentNode.insertBefore r, q
    if @getElementsByClassName("watch-sidebar-section")[0]
      unless document.getElementById("__ffYoutube4")
        google_ad = document.getElementById("google_companion_ad_div")
        style_ammend = "; display:none;"  if google_ad.innerHTML.length > 0  if google_ad
        r = document.createElement("div")
        r.innerHTML += "<div id='__ffYoutube4' style='margin-left:27px;" + style_ammend + "'>" + ad_tag_300 + "</div>"
        e = @getElementsByClassName("watch-sidebar-section")[0]
        e.parentNode.insertBefore r, e  if e
    if @getElementsByClassName("watch-module")[0]
      unless document.getElementById("__ffYoutube4")
        google_ad = document.getElementById("google_companion_ad_div")
        style_ammend = "; display:none;"  if google_ad.innerHTML.length > 0  if google_ad
        r = document.createElement("div")
        r.innerHTML += "<div id='__ffYoutube4' style='margin-left:27px;" + style_ammend + "'>" + ad_tag_300 + "</div>"
        e = @getElementsByClassName("watch-module")[0]
        e.parentNode.insertBefore r, e  if e
    if document.getElementById("main-channel-content")
      unless document.getElementById("__ffYoutube1")
        r = document.createElement("div")
        r.innerHTML += "<div id='__ffYoutube1' style='" + style_ammend + "'>" + ad_tag_728 + "</div>"
        e = document.getElementById("main-channel-content")
        e.parentNode.insertBefore r, e  if e
    if document.getElementById("homepage-side-content")
      unless document.getElementById("__ffYoutube1")
        r = document.createElement("div")
        r.innerHTML += "<div id='__ffYoutube1' style='" + style_ammend + "'>" + ad_tag_300 + "</div>"
        document.getElementById("homepage-side-content").innerHTML = r.innerHTML + document.getElementById("homepage-side-content").innerHTML

setTimeout initilizeryy, 2000  unless typeof (chrome) is "undefined"

#
# Jet pack initilizer (this is a mozilla specific thing)
# 
unless typeof (self.on) is "undefined"
  self.on "message", (data) ->
    youtubeiicdn.init()  if window is window.top

