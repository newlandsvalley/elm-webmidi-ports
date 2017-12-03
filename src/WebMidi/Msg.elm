module WebMidi.Msg exposing (..)

import WebMidi.Types exposing (..)
import Midi.Types exposing (MidiEvent)


type Msg
    = WebMidiInitialise
    | ResponseWebMidiInitialised Bool
    | RequestDevices
    | InputDeviceConnected MidiConnection
    | OutputDeviceConnected MidiConnection
    | InputDeviceDisconnected MidiDisconnection
    | OutputDeviceDisconnected MidiDisconnection
    | EncodedEvent MidiEncodedEvent
    | Event String Float (Result String MidiEvent)
    | OutEvent (Maybe String) (List MidiEvent)
