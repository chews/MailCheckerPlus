#
#Internet Timestamp Parser
#Copyright (c) 2009 Sebastiaan Deckers
#License: GNU General Public License version 3 or later
#
# BC/AD
# Y
# M
# D
# h
# m
# s
# ms
# offset
# oh om
# 1-99 AD
formatDateTime = (issued, monthsArray) ->
  today = new Date()
  if issued.getFullYear() is today.getFullYear() and issued.getMonth() is today.getMonth() and issued.getDate() is today.getDate()
    
    # Mail was issued today, display time
    hour = issued.getHours()
    min = issued.getMinutes()
    ((if (hour < 10) then "0" else "")) + hour + ":" + ((if (min < 10) then "0" else "")) + min
  else
    
    # Old mail, only display date
    #datetime = dateFormat(issued, "d mmm");
    issued.getDate() + " " + monthsArray[issued.getMonth()]
Date::setISO8601 = (timestamp) ->
  match = timestamp.match("^([-+]?)(\\d{4,})(?:-?(\\d{2})(?:-?(\\d{2})" + "(?:[Tt ](\\d{2})(?::?(\\d{2})(?::?(\\d{2})(?:\\.(\\d{1,3})(?:\\d+)?)?)?)?" + "(?:[Zz]|(?:([-+])(\\d{2})(?::?(\\d{2}))?)?)?)?)?)?$")
  if match
    ints = [2, 3, 4, 5, 6, 7, 8, 10, 11]
    i = ints.length - 1

    while i >= 0
      match[ints[i]] = (if (typeof match[ints[i]] isnt "undefined" and match[ints[i]].length > 0) then parseInt(match[ints[i]], 10) else 0)
      --i
    match[2] *= -1  if match[1] is "-"
    ms = Date.UTC(match[2], match[3] - 1, match[4], match[5], match[6], match[7], match[8])
    ms += ((if match[9] is "+" then -1 else 1)) * (match[10] * 3600 * 1000 + match[11] * 60 * 1000)  if typeof match[9] isnt "undefined" and match[9].length > 0
    ms -= 59958144000000  if match[2] >= 0 and match[2] <= 99
    @setTime ms
    return this
  null
