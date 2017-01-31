module WebMidi.Subscriptions exposing (..)

import WebMidi.Ports exposing (..)
import WebMidi.Types exposing (..)
import WebMidi.Msg exposing (..)


-- SUBSCRIPTIONS


initialisedSub : Sub Msg
initialisedSub =
    initialised ResponseWebMidiInitialised


disconnectedSub : Sub Msg
disconnectedSub =
    disconnected DeviceDisconnected


inputDeviceSub : Sub Msg
inputDeviceSub =
    inputDevice ResponseInputDevice


eventSub : Sub Msg
eventSub =
    event Event
