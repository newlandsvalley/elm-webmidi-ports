module Send exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, Attribute, map, div, p, text, input, button, select, option)
import Html.Attributes exposing (defaultValue, value, selected)
import Html.Attributes as A
import Html.Events exposing (onClick, onInput, on)
import WebMidi exposing (Model, init, update, subscriptions)
import WebMidi.Msg exposing (..)
import WebMidi.Ports exposing (initialiseWebMidi)
import WebMidi.Subscriptions exposing (eventSub)
import WebMidi.Types exposing (MidiConnection)
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
    | SendNoteOnAll
    | SendNoteOffAll
    | SendNoteOn
    | SendNoteOff
    | ChangeId String


type alias Model =
    { webMidi : WebMidi.Model
    , note : Int
    , velocity : Int
    , channel : Int
    , maybeId : Maybe String
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
        , maybeId = Nothing
        }
            ! [ Cmd.map MidiMsg webMidiCmd
              , initialiseWebMidi ()
              ]


sendNoteOnMsg channel note velocity maybeId =
   let
       bytes = [128 + 16 + channel, note, velocity]
   in
       OutEvent maybeId bytes


sendNoteOffMsg channel note velocity maybeId =
   let
       bytes = [128 + channel, note, velocity]
   in
       OutEvent maybeId bytes


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

        SendNoteOnAll ->
            let
                midiMsgOut =
                   sendNoteOnMsg model.channel model.note model.velocity Nothing
                ( newWebMidi, cmd ) =
                   WebMidi.update midiMsgOut model.webMidi
            in
                { model | webMidi = newWebMidi } ! [ Cmd.map MidiMsg cmd ]

        SendNoteOffAll ->
            let
                midiMsgOut =
                   sendNoteOffMsg model.channel model.note model.velocity Nothing
                ( newWebMidi, cmd ) =
                   WebMidi.update midiMsgOut model.webMidi
            in
                { model | webMidi = newWebMidi } ! [ Cmd.map MidiMsg cmd ]

        SendNoteOn ->
            case model.maybeId of
               Just id ->
                  let
                     midiMsgOut =
                        sendNoteOnMsg model.channel model.note model.velocity (Just id)
                     ( newWebMidi, cmd ) =
                        WebMidi.update midiMsgOut model.webMidi
                  in
                     { model | webMidi = newWebMidi } ! [ Cmd.map MidiMsg cmd ]
               Nothing -> ( model, Cmd.none )

        SendNoteOff ->
            case model.maybeId of
               Just id ->
                  let
                     midiMsgOut =
                        sendNoteOffMsg model.channel model.note model.velocity (Just id)
                     ( newWebMidi, cmd ) =
                        WebMidi.update midiMsgOut model.webMidi
                  in
                     { model | webMidi = newWebMidi } ! [ Cmd.map MidiMsg cmd ]
               Nothing -> ( model, Cmd.none )

        MidiMsg midiMsg ->
            case midiMsg of
                OutputDeviceDisconnected dev ->
                   let
                       (newWebMidi, cmd) = WebMidi.update midiMsg model.webMidi
                       newId =
                          if Just dev.id == model.maybeId
                          then List.head (Dict.keys newWebMidi.outputDevices)
                          else model.maybeId
                       newModel = { model | webMidi = newWebMidi, maybeId = newId }
                   in
                       (newModel, Cmd.map MidiMsg cmd)
                OutputDeviceConnected dev ->
                    let
                       (newWebMidi, cmd) = WebMidi.update midiMsg model.webMidi
                       newId = case model.maybeId of
                             Just id -> Just id
                             Nothing -> Just dev.id
                       newModel = { model | webMidi = newWebMidi, maybeId = newId }
                    in
                       (newModel, Cmd.map MidiMsg cmd)
                _ ->
                    let
                       ( newWebMidi, cmd ) =
                             WebMidi.update midiMsg model.webMidi
                    in
                       { model | webMidi = newWebMidi } ! [ Cmd.map MidiMsg cmd ]

        ChangeId newId -> { model | maybeId = Just (log "newId" newId) } ! []



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


viewMidiOutputs : Maybe String -> Dict String MidiConnection -> List (Html Msg)
viewMidiOutputs selectedId midiOutputs =
   let
       toOption (id, mc) =
          option
          [ value id, selected (Just id == selectedId) ]
          [ text mc.name ]
   in
       List.map toOption (Dict.toList midiOutputs)

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
            [ button [ onClick SendNoteOnAll ] [ text "Note On All" ]
            , button [ onClick SendNoteOffAll ] [ text "Note Off All" ]
            ]
        , p []
            [ select 
               [ onInput ChangeId ]
               (viewMidiOutputs model.maybeId model.webMidi.outputDevices)
            ]
        , p []
            [ button [ onClick SendNoteOn ] [ text "Note On" ]
            , button [ onClick SendNoteOff ] [ text "Note Off" ]
            ]
        ]
