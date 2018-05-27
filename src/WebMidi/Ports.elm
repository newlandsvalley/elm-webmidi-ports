port module WebMidi.Ports exposing (..)

import WebMidi.Types exposing (..)


-- outgoing ports (for commands to javascript)


{-| check if Web MIDI is supported
-}
port checkWebMidiSupport : () -> Cmd msg


{-| request web MIDI access
-}
port requestAccess : Bool -> Cmd msg


{-| send a MIDI message to all connected devices
-}
port sendMidiAll : List Int -> Cmd msg


{-| send a MIDI message to a specific device
-}
port sendMidi : ( String, List Int ) -> Cmd msg



-- incoming ports (for subscriptions from javascript)


port midiSupport : (Bool -> msg) -> Sub msg


port midiAccess : (Bool -> msg) -> Sub msg


port sysexAccess : (Bool -> msg) -> Sub msg


{-| return a MIDI input device which may be connecting or pre-connected
-}
port inputDevice : (MidiConnection -> msg) -> Sub msg


{-| return a MIDI output device which may be connecting or pre-connected
-}
port outputDevice : (MidiConnection -> msg) -> Sub msg


{-| return a MIDI input device which is disconnecting and thus about to be disconnected
-}
port inputDisconnected : (MidiDisconnection -> msg) -> Sub msg


{-| return a MIDI output device which is disconnecting and thus about to be disconnected
-}
port outputDisconnected : (MidiDisconnection -> msg) -> Sub msg


{-| return a MIDI event (e.g. note on or note off etc. -)
-}
port encodedEvent : (MidiEncodedEvent -> msg) -> Sub msg
