mailTemplate = (mail, i18n) -> """
<div class="vbox mail" id="#{ mail.id }">
      <div class="hbox border-top padded sender">
         <div class="hbox wide ">
            <label class="author" title="#{ mail.authorMail  }">#{ mail.authorName  }</label>
         </div>
         <div class="hbox mailActions">
            <label title="#{ mail.issued }">#{ formatDateTime(mail.issued, i18n.selected_lang.months) }</label>
            <a class="readLink" mailId="#{ mail.id }" href="#" title="#{ i18n.get('readLinkTitle') }">#{ i18n.get('readLink') }</a>
            <a class="deleteLink" mailId="#{ mail.id }" href="#" title="#{ i18n.get('deleteLinkTitle') }">#{ i18n.get('deleteLink') }</a>
            <a class="spamLink" mailId="#{ mail.id }" href="#" title="#{ i18n.get('spamLinkTitle') }">#{ i18n.get('spamLink') }</a>
            <a class="archiveLink" mailId="#{ mail.id }" href="#" title="#{ i18n.get('archiveLinkTitle') }">#{ i18n.get('archiveLink') }</a>
         </div>
      </div>

      <div class="hbox title padded">
         <!--<div class="hbox">
            <a class="starlink" mailId="#{ mail.id }" href="#" title="#{ i18n.get('starLinkTitle') }">#{ i18n.get('starLinkTitle') }</a>
         </div>!-->
         <div class="hbox wide">
            <a class="starLink imageLink" mailId="#{ mail.id }" href="#" title="#{ i18n.get('starLinkTitle') }"><img src="img/star.png" /></a>
            <a class="openLink" mailId="#{ mail.id }" href="#" title="#{ mail.title }">#{ mail.shortTitle }</a>
         </div>
         <div class="hbox">
            <a class="fullLink imageLink" mailId="#{ mail.id }" href="#" title="#{ i18n.get('fullLinkTitle') }"><img src="img/more.png" /></a>
            <a class="replyLink imageLink" mailId="#{ mail.id }" href="#" title="#{ i18n.get('replyLinkTitle') }"><img src="img/reply.png" /></a>
         </div>
      </div>

      <div class="vbox summary padded" mailId="#{ mail.id }">
         #{ mail.summary }
      </div>
   </div>
"""
