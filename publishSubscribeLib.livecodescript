script "publishSubscribeLib"
/*
aagPubSubLib
author: Andre Alves Garzia (contato@andregarzia.com)

A simple library implementing publisher/subscriber mechanics, also known
as the observer pattern.

== Version 2.0: (January of 2016): 
Renamed the handlers. Now they are easier to understand 
and not just a copy of a web standard.
*/

local _EVENTS

on subscribe pEvent, pCallback, pTarget, pOption
   if pTarget is empty then
      put the long id of the target into pTarget
   end if
   
   if pOption is empty then
      put "always" into pOption
   end if
   
   put pOption into _EVENTS[pEvent][pTarget][pCallback]
end subscribe

command removeAllSubscriptions
   put empty into _EVENTS
end removeAllSubscriptions

on broadcast pEvent, pData
   repeat for each key tTarget in _EVENTS[pEvent]
      repeat for each key tCallback in _EVENTS[pEvent][tTarget]
         dispatch tCallback to tTarget with pData
         if the environment is "development" then
            put tCallback && "-->" && the short name of tTarget & cr after field "debug field" of stack "aagPubSubLib"
            put "result:" && it & cr after field "debug field" of stack "aagPubSubLib"
         end if
         if _EVENTS[pEvent][tTarget][tCallback] is "once" then
            delete variable _EVENTS[pEvent][tTarget][tCallback]
         end if
      end repeat
   end repeat
end broadcast

on unsubscribe pEvent, pCallback, pTarget
   if pTarget is empty then
      put the long id of the target into pTarget
   end if
   
   if pCallback is empty then
      -- remove all callbacks for the given target
      -- if no callback is specified as a param.
      delete variable _EVENTS[pEvent][pTarget]
      pass unsubscribe
   end if
   
   repeat for each key tCallback in _EVENTS[pEvent][pTarget]
      if tCallback is pCallback then
         delete variable  _EVENTS[pEvent][pTarget][tCallback]
      end if
   end repeat
end unsubscribe

on libraryStack
   broadcast "stack in use", the short name of me
end libraryStack

