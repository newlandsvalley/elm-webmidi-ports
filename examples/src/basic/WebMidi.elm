module WebMidi exposing (..)

import Html exposing (Html, Attribute, p, text, div, input, button)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick)
import String
import Char exposing (toCode)


-- import Task

import WebMidi.Ports exposing (..)
import WebMidi.Types exposing (..)
import WebMidi.Msg exposing (..)
import WebMidi.Subscriptions exposing (..)
import CoMidi exposing (parseMidiEvent)
import MidiTypes exposing (MidiEvent)
import Debug exposing (log)


main =
    Html.program
        { init = ( init, Cmd.none ), update = update, view = view, subscriptions = subscriptions }


type alias Model =
    { initialised : Bool
    , inputDevices : List MidiConnection
    , midiEvent : Result String MidiEvent
    }


init =
    Model False [] (Err "notes not started")


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WebMidiInitialise ->
            ( model, initialise () )

        ResponseWebMidiInitialised isInitialised ->
            ( { model | initialised = isInitialised }
            , requestInputDevices ()
            )

        DeviceDisconnected disconnectedDevice ->
            ( removeDevice disconnectedDevice model
            , Cmd.none
            )

        -- not called - done directly from the Connected response
        RequestInputDevices ->
            ( model
            , Cmd.none
            )

        ResponseInputDevice connectedDevice ->
            ( addDevice connectedDevice model
            , Cmd.none
            )

        Event encodedEvent ->
            ( { model | midiEvent = parseMidiEvent encodedEvent.encodedBinary }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


addDevice : MidiConnection -> Model -> Model
addDevice device model =
    let
        isNew =
            List.filter (\d -> d.id == device.id) model.inputDevices
                |> List.isEmpty
    in
        if (isNew) then
            { model | inputDevices = device :: model.inputDevices }
        else
            model


removeDevice : MidiDisconnection -> Model -> Model
removeDevice disconnection model =
    let
        devices =
            List.filter (\d -> d.id /= disconnection.id) model.inputDevices
    in
        { model | inputDevices = devices, midiEvent = Err "notes not started" }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ initialisedSub
        , inputDeviceSub
        , disconnectedSub
        , eventSub
        ]



-- VIEW


viewInputDevices : Model -> List (Html Msg)
viewInputDevices model =
    let
        fn : MidiConnection -> Html Msg
        fn m =
            p [] [ text (toString m.name) ]
    in
        List.map fn model.inputDevices


viewMidiEvent : Model -> String
viewMidiEvent model =
    case model.midiEvent of
        Ok event ->
            log "" (toString event)

        Err msg ->
            log "parse error" msg


view : Model -> Html Msg
view model =
    div []
        [ button
            [ onClick WebMidiInitialise
            , id "web-midi-initialise"
            , btnStyle
            ]
            [ text "initialise web-midi" ]
        , p [] [ text ("initialised: " ++ (toString model.initialised)) ]
        , div [] (viewInputDevices model)
        , div [] [ text (viewMidiEvent model) ]
        ]


btnStyle : Attribute msg
btnStyle =
    style
        [ ( "font-size", "1em" )
        , ( "text-align", "center" )
        ]
