#
# Plugin storage v.01
# This file provides contentscripts access to a localstorage object or a Mozilla preferences object
# to save settings that require persistence.
#
setUppluginStorage = (response) ->
  unless typeof (chrome) is "undefined"
    pluginStorage = response
    pluginStorage.getItem = (key) ->
      return pluginStorage[key]  unless typeof (pluginStorage[key]) is "undefined"
      null

    pluginStorage.setItem = (key, value) ->
      pluginStorage[key] = value
      thisJSON =
        requestType: "localStorage"
        operation: "setItem"
        itemName: key
        itemValue: value

      chrome.extension.sendRequest thisJSON, (response) ->


    
    # this is an asynchronous response, we don't really need to do anything here...
    pluginStorage.removeItem = (key) ->
      delete pluginStorage[key]

      thisJSON =
        requestType: "localStorage"
        operation: "removeItem"
        itemName: key

      chrome.extension.sendRequest thisJSON, (response) ->


    
    # this is an asynchronous response, we don't really need to do anything here...
    window.localStorage = pluginStorage
  else unless typeof (safari) is "undefined"
    pluginStorage = response
    pluginStorage.getItem = (key) ->
      return pluginStorage[key]  unless typeof (pluginStorage[key]) is "undefined"
      null

    pluginStorage.setItem = (key, value) ->
      pluginStorage[key] = value
      thisJSON =
        requestType: "localStorage"
        operation: "setItem"
        itemName: key
        itemValue: value

      safari.self.tab.dispatchMessage "localStorage", thisJSON

    pluginStorage.removeItem = (key) ->
      delete pluginStorage[key]

      thisJSON =
        requestType: "localStorage"
        operation: "removeItem"
        itemName: key

      safari.self.tab.dispatchMessage "localStorage", thisJSON

    window.localStorage = pluginStorage
  else unless typeof (opera) is "undefined"
    pluginStorage = response
    pluginStorage.getItem = (key) ->
      return pluginStorage[key]  unless typeof (pluginStorage[key]) is "undefined"
      null

    pluginStorage.setItem = (key, value) ->
      pluginStorage[key] = value
      thisJSON =
        requestType: "localStorage"
        operation: "setItem"
        itemName: key
        itemValue: value

      opera.extension.postMessage JSON.stringify(thisJSON)

    pluginStorage.removeItem = (key) ->
      delete pluginStorage[key]

      thisJSON =
        requestType: "localStorage"
        operation: "removeItem"
        itemName: key

      opera.extension.postMessage JSON.stringify(thisJSON)

    window.localStorage = pluginStorage
  else
    pluginStorage = {}
    prefManager = Components.classes["@mozilla.org/preferences-service;1"].getService(Components.interfaces.nsIPrefBranch)
    pluginStorage.getItem = (key) ->
      prefString = ""
      try
        prefString = prefManager.getCharPref(key)
      if prefString is "" or not prefString
        null
      else
        prefManager.getCharPref key

    pluginStorage.setItem = (key, value) ->
      unless typeof (value) is "undefined"
        
        # if ((typeof(value) == 'number') && (value > 2147483647)) {
        value = value.toString()  if typeof (value) is "number"
        prefManager.setCharPref key, value
      true

    pluginStorage.removeItem = (key) ->
      prefManager.clearUserPref key
      true
bootStrap = ->
  unless typeof (opera) is "undefined"
    opera.extension.addEventListener "message", operaMessageHandler, false
    window.addEventListener "DOMContentLoaded", ((u) ->
      thisJSON = requestType: "getLocalStorage"
      opera.extension.postMessage JSON.stringify(thisJSON)
    ), false
  else
    ((u) ->
      unless typeof (chrome) is "undefined"
        thisJSON = requestType: "getLocalStorage"
        chrome.extension.sendRequest thisJSON, (response) ->
          setUppluginStorage response

      
      #console.log('setup storage');
      else unless typeof (safari) is "undefined"
        thisJSON = requestType: "getLocalStorage"
        safari.self.tab.dispatchMessage "getLocalStorage", thisJSON
    )()
pluginStorage = {}
bootStrap()
