module WebMidi.Msg exposing (..)

import WebMidi.Types exposing (..)


type Msg
    = WebMidiInitialise
    | ResponseWebMidiInitialised Bool
    | RequestInputDevices
    | ResponseInputDevice MidiConnection
    | DeviceDisconnected MidiDisconnection
    | Event MidiEncodedEvent
