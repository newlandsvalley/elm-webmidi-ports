module Send exposing (..)

import Html exposing (Html, Attribute, map, div, p, text, input, button)
import Html.Attributes exposing (defaultValue)
import Html.Attributes as A
import Html.Events exposing (onClick, onInput)
import WebMidi exposing (Model, init, update, subscriptions)
import WebMidi.Msg exposing (..)
import WebMidi.Ports exposing (initialiseWebMidi)
import WebMidi.Subscriptions exposing (eventSub)
import MidiTypes exposing (MidiEvent(..))
import Debug exposing (log)


{- This program allows you to send note on and note off midi messages to all
   connected MIDI devices.
-}


main =
    Html.program
        { init = init, update = update, view = view, subscriptions = subscriptions }


type Msg
    = MidiMsg WebMidi.Msg.Msg
    | ChangeNote Int
    | ChangeVelocity Int
    | ChangeChannel Int
    | BadVal
    | SendNoteOn
    | SendNoteOff


type alias Model =
    { webMidi : WebMidi.Model
    , note : Int
    , velocity : Int
    , channel : Int
    }


init : ( Model, Cmd Msg )
init =
    let
        ( webMidi, webMidiCmd ) =
            WebMidi.init
    in
        { webMidi = webMidi
        , note = 36
        , velocity = 127
        , channel = 0
        }
            ! [ Cmd.map MidiMsg webMidiCmd
              , initialiseWebMidi ()
              ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeNote newNote ->
           { model | note = newNote } ! []

        ChangeVelocity newVel ->
           { model | velocity = newVel } ! []

        ChangeChannel newChannel ->
           { model | channel = newChannel } ! []

        BadVal -> model ! []

        SendNoteOn ->
            let
               midiMsgOut = OutEvent [128 + 16 + model.channel, model.note, model.velocity]
               ( newWebMidi, cmd ) =
                     WebMidi.update midiMsgOut model.webMidi
            in
               { model | webMidi = newWebMidi } ! [ Cmd.map MidiMsg cmd ]

        SendNoteOff ->
            let
               midiMsgOut = OutEvent [128 + model.channel, model.note, model.velocity]
               ( newWebMidi, cmd ) =
                     WebMidi.update midiMsgOut model.webMidi
            in
               { model | webMidi = newWebMidi } ! [ Cmd.map MidiMsg cmd ]

        MidiMsg midiMsg ->
            let
               ( newWebMidi, cmd ) =
                     WebMidi.update midiMsg model.webMidi
            in
               { model | webMidi = newWebMidi } ! [ Cmd.map MidiMsg cmd ]



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map MidiMsg (WebMidi.subscriptions model.webMidi) ]


initialisationStatus : Model -> String
initialisationStatus model =
     case model.webMidi.initialised of
         True -> "Ready to send"
         False -> "Web MIDI is not initialised"


noteUpdated : String -> Msg
noteUpdated str =
     case (String.toInt str) of
         Ok newNote -> ChangeNote newNote
         Err _ -> BadVal


velocityUpdated : String -> Msg
velocityUpdated str =
     case (String.toInt str) of
         Ok newVel -> ChangeVelocity newVel
         Err _ -> BadVal


channelUpdated : String -> Msg
channelUpdated str =
     case (String.toInt str) of
         Ok newChannel -> ChangeChannel (newChannel - 1)
         Err _ -> BadVal


view : Model -> Html Msg
view model =
    div []
        [ p [] [ text (initialisationStatus model) ]
        , p []
            [ text "Note: "
            , input [ onInput noteUpdated, defaultValue "36", A.min "0", A.max "127", A.step "1", A.type_ "number" ] [] 
            ]
        , p [] [
              text "Velocity: "
            , input [ onInput velocityUpdated, defaultValue "127", A.min "0", A.max "127", A.type_ "number" ] [] 
            ]
        , p [] [
              text "Channel: "
            , input [ onInput channelUpdated, defaultValue "1", A.min "1", A.max "16", A.type_ "number" ] [] 
            ]
        , p []
            [ button [ onClick SendNoteOn ] [ text "Note On" ]
            , button [ onClick SendNoteOff ] [ text "Note Off" ]
            ]
        ]
