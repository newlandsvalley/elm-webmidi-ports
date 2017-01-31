port module WebMidi.Ports exposing (..)

import WebMidi.Types exposing (..)


-- outgoing ports (for commands to javascript)


{-| attempt to connect to Web-Midi ?
-}
port initialise : () -> Cmd msg


{-| request the MIDI input devices that are attached
-}
port requestInputDevices : () -> Cmd msg



-- incoming ports (for subscriptions from javascript)


{-| response to say whether web-midi is initialised
-}
port initialised : (Bool -> msg) -> Sub msg


{-| return a MIDI input device which may be connecting or pre-connected
-}
port inputDevice : (MidiConnection -> msg) -> Sub msg


{-| return a MIDI input device which is disconnecting and thus about to be disconnected
-}
port disconnected : (MidiDisconnection -> msg) -> Sub msg


{-| return a MIDI event (e.g. note on or note off etc. -)
-}
port event : (MidiEncodedEvent -> msg) -> Sub msg
