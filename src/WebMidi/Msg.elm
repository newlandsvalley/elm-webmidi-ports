module WebMidi.Msg exposing (..)

import WebMidi.Types exposing (..)
import MidiTypes exposing (MidiEvent)


type Msg
    = WebMidiInitialise
    | ResponseWebMidiInitialised Bool
    | RequestInputDevices
    | ResponseInputDevice MidiConnection
    | DeviceDisconnected MidiDisconnection
    | EncodedEvent MidiEncodedEvent
    | Event (Result String MidiEvent)
