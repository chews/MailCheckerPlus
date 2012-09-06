// Generated by CoffeeScript 1.3.3
var mailTemplate;

mailTemplate = function(mail, i18n) {
  return "<div class=\"vbox mail\" id=\"" + mail.id + "\">\n      <div class=\"hbox border-top padded sender\">\n         <div class=\"hbox wide \">\n            <label class=\"author\" title=\"" + mail.authorMail + "\">" + mail.authorName + "</label>\n         </div>\n         <div class=\"hbox mailActions\">\n            <label title=\"" + mail.issued + "\">" + (formatDateTime(mail.issued, i18n.selected_lang.months)) + "</label>\n            <a class=\"readLink\" mailId=\"" + mail.id + "\" href=\"#\" title=\"" + (i18n.get('readLinkTitle')) + "\">" + (i18n.get('readLink')) + "</a>\n            <a class=\"deleteLink\" mailId=\"" + mail.id + "\" href=\"#\" title=\"" + (i18n.get('deleteLinkTitle')) + "\">" + (i18n.get('deleteLink')) + "</a>\n            <a class=\"spamLink\" mailId=\"" + mail.id + "\" href=\"#\" title=\"" + (i18n.get('spamLinkTitle')) + "\">" + (i18n.get('spamLink')) + "</a>\n            <a class=\"archiveLink\" mailId=\"" + mail.id + "\" href=\"#\" title=\"" + (i18n.get('archiveLinkTitle')) + "\">" + (i18n.get('archiveLink')) + "</a>\n         </div>\n      </div>\n\n      <div class=\"hbox title padded\">\n         <!--<div class=\"hbox\">\n            <a class=\"starlink\" mailId=\"" + mail.id + "\" href=\"#\" title=\"" + (i18n.get('starLinkTitle')) + "\">" + (i18n.get('starLinkTitle')) + "</a>\n         </div>!-->\n         <div class=\"hbox wide\">\n            <a class=\"starLink imageLink\" mailId=\"" + mail.id + "\" href=\"#\" title=\"" + (i18n.get('starLinkTitle')) + "\"><img src=\"img/star.png\" /></a>\n            <a class=\"openLink\" mailId=\"" + mail.id + "\" href=\"#\" title=\"" + mail.title + "\">" + mail.shortTitle + "</a>\n         </div>\n         <div class=\"hbox\">\n            <a class=\"fullLink imageLink\" mailId=\"" + mail.id + "\" href=\"#\" title=\"" + (i18n.get('fullLinkTitle')) + "\"><img src=\"img/more.png\" /></a>\n            <a class=\"replyLink imageLink\" mailId=\"" + mail.id + "\" href=\"#\" title=\"" + (i18n.get('replyLinkTitle')) + "\"><img src=\"img/reply.png\" /></a>\n         </div>\n      </div>\n\n      <div class=\"vbox summary padded\" mailId=\"" + mail.id + "\">\n         " + mail.summary + "\n      </div>\n   </div>";
};