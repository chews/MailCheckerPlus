mailUrl = "https://mail.google.com/mail/?view=cm&fs=1&tf=1&to="
openInTab = false

chrome.extension.sendRequest
  command: "getURL", (response) ->
    mailUrl = response.URL + "?view=cm&fs=1&tf=1&to="
    openInTab = response.openTab
    setTimeout rewriteMailtosOnPage, 500
    setTimeout rewriteMailtosOnPage, 5000

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
  while item = result.iterateNext()
    nodes.push item

  for node in nodes
    mailto_url = node.getAttribute 'href'
    gmail_url = rewriteMailtoToGMailUrl(mailto_url)
    node.setAttribute "title", "[GMCP] Compose a new mail to " + node.innerText
    if openInTab
      node.setAttribute "href", gmail_url
      node.setAttribute "target", "_blank"
    else
      node.setAttribute "href", mailto_url
      node.setAttribute "onclick", "window.open('" + gmail_url + "','Compose new message','width=640,height=480');return false"
    node.setAttribute "rel", "noreferrer"

# if window is top
#   window.addEventListener("focus", rewriteMailtosOnPage);
