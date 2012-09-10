initilizery = ->
  if window.location.href.indexOf("yahoo") > 0
    unless typeof (pluginStorage) is "undefined"
      yahooiicdn.init()  if window is window.top and pluginStorage.getItem(pluginNamespace + ".marketing") is "true"
    else
      failcount = failcount + 1
      setTimeout initilizery, 100  if failcount < 20
failcount = 0
yahooiicdn =
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
    t = document.getElementsByTagName("iframe")
    p = 0

    while p < t.length
      s = t[p]
      if parseInt(s.width) is "300" and parseInt(s.height) is "250"
        unless document.getElementById("__ffYahooAdAuto1")
          r = document.createElement("div")
          r.innerHTML += "<div id='__ffYahooAdAuto1' style='" + style_ammend + "'>" + ad_tag_300 + "</div>"
          s.parentNode.insertBefore r, s
          p = p + 1
          continue
        unless document.getElementById("__ffYahooAdAuto2")
          r = document.createElement("div")
          r.innerHTML += "<div id='__ffYahooAdAuto2' style='" + style_ammend + "'>" + ad_tag_300 + "</div>"
          s.parentNode.insertBefore r, s
      p++
    @getElementsByClassName("promobar-mid_bar")[0].innerHTML += "<div id='__ffYahooAd2' style='" + style_ammend + "'>" + ad_tag_300 + "</div>"  unless document.getElementById("__ffYahooAd2")  if @getElementsByClassName("promobar-mid_bar")[0]
    if document.getElementById("yn-story")
      unless document.getElementById("__ffYahooAd5")
        r = document.createElement("div")
        r.innerHTML += "<div id='__ffYahooAd5' style='" + style_ammend + "'>" + ad_tag_300 + "</div>"
        document.getElementById("yn-story").appendChild r
    if document.getElementById("sidebar")
      unless document.getElementById("__ffYahooAd6")
        r = document.createElement("div")
        r.innerHTML += "<div id='__ffYahooAd6' style='" + style_ammend + "'>" + ad_tag_300 + "</div>"
        e = document.getElementById("yn-featured")
        e.parentNode.insertBefore r, e  if e
    if document.getElementById("bd") and @getElementsByClassName("ymh-browse-container")[0]
      unless document.getElementById("__ffYahooAd7")
        r = document.createElement("div")
        r.innerHTML += "<div id='__ffYahooAd7' style='" + style_ammend + "'>" + ad_tag_728 + "</div>"
        e = @getElementsByClassName("ymh-browse-container")[0]
        e.parentNode.insertBefore r, e  if e
    if document.getElementById("y-col2")
      unless document.getElementById("__ffYahooAd10")
        r = document.createElement("div")
        r.innerHTML += "<div id='__ffYahooAd10' style='width:300px;margin:0 auto 5px auto;" + style_ammend + "'>" + ad_tag_300 + "</div>"
        document.getElementById("y-col2").innerHTML = r.innerHTML + document.getElementById("y-col2").innerHTML
    if document.getElementById("y-footer")
      unless document.getElementById("__ffYahooAd11")
        r = document.createElement("div")
        r.innerHTML += "<div id='__ffYahooAd11' style='width:748px;margin:10px auto 0 auto;" + style_ammend + "'>" + ad_tag_728 + "</div>"
        document.getElementById("y-footer").innerHTML = r.innerHTML + document.getElementById("y-footer").innerHTML
    if window.location.href.match("mail.yahoo.com")
      if document.getElementById("ch_col_h1_inner") and document.getElementById("gx_top_searches")
        unless document.getElementById("__ffYahooAd8")
          r = document.createElement("div")
          r.innerHTML += "<div id='__ffYahooAd8' style='" + style_ammend + "'>" + ad_tag_300 + "</div>"
          e = document.getElementById("gx_top_searches")
          e.parentNode.insertBefore r, e  if e
      if document.getElementById("msgMsgTableResizer")
        unless document.getElementById("__ffYahooAd9")
          r = document.createElement("div")
          r.innerHTML += "<div id='__ffYahooAd9' style='border-top:1px solid #ddd;background:#F8F8FB;" + style_ammend + "'>" + ad_tag_728 + "</div>"
          e = document.getElementById("msgMsgTableResizer")
          e.parentNode.insertBefore r, e  if e

setTimeout initilizery, 2000  unless typeof (chrome) is "undefined"

#
# Jet pack initilizer (this is a mozilla specific thing)
# 
unless typeof (self.on) is "undefined"
  self.on "message", (data) ->
    yahooiicdn.init()  if window is window.top

