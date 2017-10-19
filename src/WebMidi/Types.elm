module WebMidi.Types exposing (..)

{-| A MidiConnection - could be used for both input and output devices but only inputs are currently supported
-}


type alias MidiConnection =
    { portType : String
    , id : String
    , manufacturer : String
    , name : String
    , version : String
    }


{-| A Midi Disconnection of a device previously connected
-}
type alias MidiDisconnection =
    { portType : String
    , id : String
    }


{-| a MIDI event with the event data encoded as a string which is amenable to parsing
-}
type alias MidiEncodedEvent =
    { id : String
    , timeStamp : Float
    , encodedBinary : String
    }
