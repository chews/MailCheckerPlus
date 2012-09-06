notifyTemplate = (account, datetime, i18n, mail) -> """
<div class="indicator i#{ account.id % 4 }">
   <div id="inbox_#{ account.id }" class="vbox rounded">
      <div class="vbox" id="#{ mail.id }">
         <div class="hbox address padded">
            <div><a class="inboxLink" title="#{ account.getInboxLink() }">#{ account.getAddress() }</a></div>
         </div>

         <div class="hbox sender">
            <div class="hbox wide padded">
               <a class="author" href="mailto:#{ mail.authorMail  }" title="#{ mail.authorMail  }">#{ mail.authorName  }</a>
            </div>
            <div class="hbox padded">
               <label>#{ datetime }</label>
            </div>
         </div>

         <div class="hbox title">
            <div class="hbox wide padded">
               <a class="starLink imageLink" mailId="#{ mail.id }" href="#" title="#{ i18n.get('starLinkTitle') }"><img src="img/star.png" /></a>
               <a class="openLink" mailId="#{ mail.id }" href="#" title="#{ mail.title }">#{ mail.shortTitle }</a>
            </div>
         </div>

         <div class="hbox">
            <div class="hbox wide border-top padded summary" mailId="#{ mail.id }">
               #{ mail.summary }
            </div>
         </div>

         <div class="hbox padded hiddenSummaryActions">
            <a class="readLink" mailId="#{ mail.id }" title="#{ i18n.get('readLinkTitle') }">#{ i18n.get('readLink') }</a>
            &nbsp;
            <a class="deleteLink" mailId="#{ mail.id }" title="#{ i18n.get('deleteLinkTitle') }">#{ i18n.get('deleteLink') }</a>
            &nbsp;
            <a class="spamLink" mailId="#{ mail.id }" title="#{ i18n.get('spamLinkTitle') }">#{ i18n.get('spamLink') }</a>
            &nbsp;
            <a class="archiveLink" mailId="#{ mail.id }" title="#{ i18n.get('archiveLinkTitle') }">#{ i18n.get('archiveLink') }</a>
         </div>
      </div>
   </div>
</div>
"""
