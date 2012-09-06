accountTemplate = (account, i18n) ->
  if account.unreadCount > 0
    unreadCount = """<span class="unreadCount">(#{ account.unreadCount })</span>"""
  else
    unreadCount = ""

  template = """
    <div id="content_#{ account.id }" class="indicator i#{ account.id % 4 } account">
       <div id="inbox_#{ account.id }" class="vbox rounded">
           <div class="hbox padded inbox">
               <div class="hbox padded wide">
                  <a class="toggleLink imageLink" accountId="#{ account.id }" href="#" title=""><img src="img/arrow_down.png" /></a>
                  <a class="inboxLink" accountId="#{ account.id }" href="#" title="#{ account.getInboxLink() }">
                    #{ account.getInboxLink() }
                    #{unreadCount}
                  </a>
               </div>
               <div class="hbox padded" style="padding-right: 0">
                   <a class="composeLink imageLink" accountId="#{ account.id }" href="#" title="#{ i18n.get('composeLinkTitle') }"><img src="img/compose.png" /></a>
                   <a class="sendpageLink imageLink" accountId="#{ account.id }" href="#" title="#{ i18n.get('sendPageLinkTitle') }"><img src="img/send_page.png" /></a>
               </div>
           </div>
       </div>
    </div>
    """
