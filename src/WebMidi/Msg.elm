module WebMidi.Msg exposing (..)

import WebMidi.Types exposing (..)
import MidiTypes exposing (MidiEvent)


type Msg
    = WebMidiInitialise
    | ResponseWebMidiInitialised Bool
    | RequestDevices
    | ResponseInputDevice MidiConnection
    | ResponseOutputDevice MidiConnection
    | InputDeviceDisconnected MidiDisconnection
    | OutputDeviceDisconnected MidiDisconnection
    | EncodedEvent MidiEncodedEvent
    | Event (Result String MidiEvent)
    | OutEvent (List Int)
