module WebMidi exposing (Model, init, update, view, subscriptions)

import Dict exposing (Dict)
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
import Midi.Parse
import Midi.Types exposing (MidiEvent(..))
import Midi.Generate as Generate
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
    { midiSupported : Maybe Bool
    , midiAccess : Bool
    , sysexAccess : Bool
    , inputDevices : Dict String MidiConnection
    , outputDevices : Dict String MidiConnection
    , lastMidiMessage : String
    , maxVolume : Int
    }


initialModel =
    { midiSupported = Nothing
    , midiAccess = False
    , sysexAccess = False
    , inputDevices = Dict.empty
    , outputDevices = Dict.empty
    , lastMidiMessage = "notes not started"
    , maxVolume = (volumeCeiling // 2)
    }


init =
    ( initialModel
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CheckWebMidiSupport ->
            ( model, checkWebMidiSupport () )

        InputDeviceDisconnected disconnectedDevice ->
            ( removeInputDevice disconnectedDevice model
            , Cmd.none
            )

        OutputDeviceDisconnected disconnectedDevice ->
            ( removeOutputDevice disconnectedDevice model
            , Cmd.none
            )

        RequestAccess requestSysex ->
            ( model
            , requestAccess requestSysex
            )

        MidiSupportStatus midiSupported ->
            ( { model | midiSupported = Just midiSupported }
            , Cmd.none
            )

        MidiAccessStatus midiAccess ->
            ( { model | midiAccess = midiAccess }
            , Cmd.none
            )

        SysexAccessStatus sysexAccess ->
            ( { model | sysexAccess = sysexAccess }
            , Cmd.none
            )

        InputDeviceConnected connectedDevice ->
            ( addInputDevice connectedDevice model
            , Cmd.none
            )

        OutputDeviceConnected connectedDevice ->
            ( addOutputDevice connectedDevice model
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
                    Midi.Parse.event encodedEvent.encodedBinary

                -- intercept any control messages we care about
                newModel =
                    recogniseControlMessage midiEvent model

                -- package everything up into an event
                outEvent =
                    Event encodedEvent.id encodedEvent.timeStamp midiEvent
            in
                ( newModel
                , forwardMsg outEvent
                )

        -- we do export a decoded event
        Event id timeStamp event ->
            let
                deviceName =
                    case Dict.get id model.inputDevices of
                        Just device ->
                            device.name

                        Nothing ->
                            "unknown"

                midiMsg =
                    (toString event)
                        ++ " from "
                        ++ deviceName
                        ++ " at "
                        ++ (toString timeStamp)
            in
                ( { model | lastMidiMessage = midiMsg }
                , Cmd.none
                )

        OutEvent maybeId events ->
            let
                bytes =
                    List.concatMap Generate.event events
            in
                case maybeId of
                    Just id ->
                        ( model
                        , sendMidi ( id, bytes )
                        )

                    Nothing ->
                        ( model
                        , sendMidiAll bytes
                        )


addInputDevice : MidiConnection -> Model -> Model
addInputDevice device model =
    let
        devices =
            Dict.insert device.id device model.inputDevices
    in
        { model | inputDevices = devices }


addOutputDevice : MidiConnection -> Model -> Model
addOutputDevice device model =
    let
        devices =
            Dict.insert device.id device model.outputDevices
    in
        { model | outputDevices = devices }


removeInputDevice : MidiDisconnection -> Model -> Model
removeInputDevice disconnection model =
    let
        devices =
            Dict.remove disconnection.id model.inputDevices
    in
        { model | inputDevices = devices }


removeOutputDevice : MidiDisconnection -> Model -> Model
removeOutputDevice disconnection model =
    let
        devices =
            Dict.remove disconnection.id model.outputDevices
    in
        { model | outputDevices = devices }


forwardMsg : Msg -> Cmd Msg
forwardMsg msg =
    Task.perform identity (succeed msg)


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
        [ midiSupportSub
        , midiAccessSub
        , sysexAccessSub
        , inputDeviceSub
        , outputDeviceSub
        , inputDisconnectedSub
        , outputDisconnectedSub
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
        List.map fn (Dict.values model.inputDevices)


viewOutputDevices : Model -> List (Html Msg)
viewOutputDevices model =
    let
        fn : MidiConnection -> Html Msg
        fn m =
            p [] [ text (toString m.name) ]
    in
        List.map fn (Dict.values model.outputDevices)


view : Model -> Html Msg
view model =
    div []
        [ button
            [ onClick CheckWebMidiSupport
            , id "web-midi-check-support"
            , btnStyle
            ]
            [ text "check web MIDI support" ]
        , button
            [ onClick (RequestAccess False)
            , id "web-midi-request-access"
            , btnStyle
            ]
            [ text "request web MIDI access" ]
        , button
            [ onClick (RequestAccess True)
            , id "web-midi-request-access-with-sysex"
            , btnStyle
            ]
            [ text "request web MIDI access (with SysEx)" ]
        , p [] [ text ("web MIDI support: " ++ (toString model.midiSupported)) ]
        , p [] [ text ("MIDI access: " ++ (toString model.midiAccess)) ]
        , p [] [ text ("SysEx access: " ++ (toString model.sysexAccess)) ]
        , p [] [ text "Inputs:" ]
        , div [ style [ ( "margin-left", "5%" ) ] ] (viewInputDevices model)
        , p [] [ text "Outputs:" ]
        , div [ style [ ( "margin-left", "5%" ) ] ] (viewOutputDevices model)
        , div [] [ text model.lastMidiMessage ]
        , div [] [ text ("max volume : " ++ (toString model.maxVolume)) ]
        ]


btnStyle : Attribute msg
btnStyle =
    style
        [ ( "font-size", "1em" )
        , ( "text-align", "center" )
        ]
