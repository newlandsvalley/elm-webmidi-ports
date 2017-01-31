module WebMidi.Msg exposing (..)

import Maybe exposing (Maybe)
import WebMidi.Types exposing (..)


type Msg
    = WebMidiInitialise
    | ResponseWebMidiInitialised Bool
    | RequestInputDevices
    | ResponseInputDevice MidiConnection
    | DeviceDisconnected MidiDisconnection
    | Event MidiEncodedEvent
    | NoOp
