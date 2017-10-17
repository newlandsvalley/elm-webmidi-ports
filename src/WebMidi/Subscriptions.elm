module WebMidi.Subscriptions exposing (..)

import WebMidi.Ports exposing (..)
import WebMidi.Types exposing (..)
import WebMidi.Msg exposing (..)


-- SUBSCRIPTIONS


initialisedSub : Sub Msg
initialisedSub =
    initialised ResponseWebMidiInitialised


inputDisconnectedSub : Sub Msg
inputDisconnectedSub =
    inputDisconnected InputDeviceDisconnected


outputDisconnectedSub : Sub Msg
outputDisconnectedSub =
    outputDisconnected OutputDeviceDisconnected


inputDeviceSub : Sub Msg
inputDeviceSub =
    inputDevice ResponseInputDevice


outputDeviceSub : Sub Msg
outputDeviceSub =
    outputDevice ResponseOutputDevice


eventSub : Sub Msg
eventSub =
    encodedEvent EncodedEvent
