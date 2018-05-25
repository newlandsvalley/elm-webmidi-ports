module WebMidi.Subscriptions exposing (..)

import WebMidi.Ports exposing (..)
import WebMidi.Types exposing (..)
import WebMidi.Msg exposing (..)


-- SUBSCRIPTIONS


midiSupportSub : Sub Msg
midiSupportSub =
    midiSupport MidiSupportStatus


midiAccessSub : Sub Msg
midiAccessSub =
    midiAccess MidiAccessStatus


sysexAccessSub : Sub Msg
sysexAccessSub =
    sysexAccess SysexAccessStatus


inputDeviceSub : Sub Msg
inputDeviceSub =
    inputDevice InputDeviceConnected


inputDisconnectedSub : Sub Msg
inputDisconnectedSub =
    inputDisconnected InputDeviceDisconnected


outputDeviceSub : Sub Msg
outputDeviceSub =
    outputDevice OutputDeviceConnected


outputDisconnectedSub : Sub Msg
outputDisconnectedSub =
    outputDisconnected OutputDeviceDisconnected


eventSub : Sub Msg
eventSub =
    encodedEvent EncodedEvent
