port module WebMidi.Ports exposing (..)

import WebMidi.Types exposing (..)


-- outgoing ports (for commands to javascript)


{-| attempt to connect to Web-Midi ?
-}
port initialiseWebMidi : () -> Cmd msg


{-| request the MIDI devices that are attached
-}
port requestDevices : () -> Cmd msg



-- incoming ports (for subscriptions from javascript)


{-| response to say whether web-midi is initialised
-}
port initialised : (Bool -> msg) -> Sub msg


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
