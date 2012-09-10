{
  "type": "block",
  "src": "{",
  "value": "{",
  "lineno": 62,
  "children": [],
  "varDecls": [],
  "labels": {
    "table": {},
    "size": 0
  },
  "functions": [],
  "nonfunctions": [],
  "transformed": true
}
rewriteMailtoToGMailUrl = (inUrl) ->
  retUrl = inUrl
  subject = retUrl.match(/subject=([^&]*)/i)
  if subject?
    subject = encodeURIComponent(unescape(subject[1]))
    retUrl = retUrl.replace(/subject=([^&]*)/i, "su=" + subject)
  retUrl = retUrl.replace("?", "&")
  retUrl = retUrl.replace(/CC=/i, "cc=")
  retUrl = retUrl.replace(/BCC=/i, "bcc=")
  retUrl = retUrl.replace(/Body=/i, "body=")
  retUrl = retUrl.replace(/mailto:/i, mailUrl)
  retUrl

# Content Scripts
rewriteMailtosOnPage = ->
  
  # Find all the mailto links.
  xpath = "//a[contains(" + "translate(@href," + "'ABCDEFGHIJKLMNOPQRSTUVWXYZ'," + "'abcdefghijklmnopqrstuvwxyz')," + "'mailto:')]"
  result = document.evaluate(xpath, document, null, XPathResult.UNORDERED_NODE_ITERATOR_TYPE, null)
  item = undefined
  nodes = []
  
  # cannot change the NODE_ITERATOR nodes' attributes in this loop itself
  # since iterateNext will invalidate the state; Need to store temporarily.
  nodes.push item  while item = result.iterateNext()
  i = 0

  while i < nodes.length
    mailto_url = nodes[i].getAttribute("href")
    gmail_url = rewriteMailtoToGMailUrl(mailto_url)
    nodes[i].setAttribute "title", "[GMCP] Compose a new mail to " + nodes[i].innerText
    if openInTab
      nodes[i].setAttribute "href", gmail_url
      nodes[i].setAttribute "target", "_blank"
    else
      nodes[i].setAttribute "href", mailto_url
      nodes[i].setAttribute "onclick", "window.open('" + gmail_url + "','Compose new message','width=640,height=480');return false"
    nodes[i].setAttribute "rel", "noreferrer"
    i++
mailUrl = "https://mail.google.com/mail/?view=cm&fs=1&tf=1&to="
openInTab = false
chrome.extension.sendRequest
  command: "getURL"
, (response) ->
  mailUrl = response.URL + "?view=cm&fs=1&tf=1&to="
  openInTab = response.openTab
  setTimeout "rewriteMailtosOnPage()", 500
  setTimeout "rewriteMailtosOnPage()", 5000

window is top

#window.addEventListener("focus", rewriteMailtosOnPage);
