module WebMidi exposing (Model, init, update, view, subscriptions)

import Html exposing (Html, Attribute, p, text, div, button)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Char exposing (toCode)
import Basics exposing (never)
import Task exposing (Task, perform, succeed)
import WebMidi.Ports exposing (..)
import WebMidi.Types exposing (..)
import WebMidi.Msg exposing (..)
import WebMidi.Subscriptions exposing (..)
import CoMidi exposing (parseMidiEvent)
import MidiTypes exposing (MidiEvent(..))
import Debug exposing (log)


main =
    Html.program
        { init = init, update = update, view = view, subscriptions = subscriptions }


{-| volumes in MIDI range from 0 to 127
-}
volumeCeiling : Int
volumeCeiling =
    127



-- type Msg = WebMidi.Msg.Msg


type alias Model =
    { initialised : Bool
    , inputDevices : List MidiConnection
    , midiEvent : Result String MidiEvent
    , maxVolume : Int
    }


init =
    ( Model False [] (Err "notes not started") (volumeCeiling // 2)
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WebMidiInitialise ->
            ( model, initialiseWebMidi () )

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

        -- we don't export encodedEvent (which is there to satisfy the port)
        EncodedEvent encodedEvent ->
            {- we don't do the simple thing:
                 update (Event (parseMidiEvent encodedEvent.encodedBinary)) model
               because we want to expose the Event message to clients which will happen
               if we forward the message through the Effects system
            -}
            let
                -- parse the MIDI event
                midiEvent =
                    parseMidiEvent encodedEvent.encodedBinary

                -- intercept any control messages we care about
                newModel =
                    recogniseControlMessage midiEvent model
            in
                ( newModel
                , forwardEvent (midiEvent)
                )

        -- we do export a dcoded event
        Event event ->
            ( { model | midiEvent = event }
            , Cmd.none
            )


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


forwardEvent : Result String MidiEvent -> Cmd Msg
forwardEvent event =
    Task.perform Event (succeed event)


{-| recognise and act on a control message and save to the model state
    At the moment, we just recognise volume changes
-}
recogniseControlMessage : Result String MidiEvent -> Model -> Model
recogniseControlMessage event model =
    case event of
        Ok midiEvent ->
            case midiEvent of
                -- 7 is the volume control
                ControlChange channel 7 amount ->
                    { model | maxVolume = amount }

                _ ->
                    model

        Err _ ->
            model



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
        , div [] [ text ("max volume : " ++ (toString model.maxVolume)) ]
        ]


btnStyle : Attribute msg
btnStyle =
    style
        [ ( "font-size", "1em" )
        , ( "text-align", "center" )
        ]
