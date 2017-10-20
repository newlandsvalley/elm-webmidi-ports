module MidiInstrument exposing (..)

import Html exposing (Html, Attribute, map, div, p, span, text, select, option)
import Html.Events exposing (on, targetValue)
import Html.Attributes exposing (style, selected)
import Json.Decode as Json
import Dict exposing (Dict, fromList, get)
import Maybe exposing (withDefault)
import WebMidi exposing (Model, init, update, subscriptions)
import WebMidi.Msg exposing (..)
import WebMidi.Ports exposing (initialiseWebMidi)
import WebMidi.Subscriptions exposing (eventSub)
import MidiTypes exposing (MidiEvent(..))
import SoundFont.Ports exposing (..)
import SoundFont.Types exposing (..)
import SoundFont.Msg exposing (..)
import SoundFont.Subscriptions exposing (..)
import Debug exposing (log)


{- This program allows you to attach a MIDI keyboard and then play it as
   a simple piano through the browser.  It only responds to MIDI note on events.
-}


main =
    Html.program
        { init = init, update = update, view = view, subscriptions = subscriptions }


type Msg
    = MidiMsg WebMidi.Msg.Msg
    | SoundFontMsg SoundFont.Msg.Msg
    | ChangeInstrument String


type alias Model =
    { audioContext : Maybe AudioContext
    , fontsLoaded : Bool
    , instrument : String
    , webMidi : WebMidi.Model
    }


instruments : List ( String, String )
instruments =
    [ ( "grand piano", "acoustic_grand_piano" )
    , ( "acoustic guitar", "acoustic_guitar_nylon" )
    , ( "bassoon", "bassoon" )
    , ( "cello", "cello" )
    , ( "harp", "orchestral_harp" )
    , ( "harpsichord", "harpsichord" )
    , ( "marimba", "marimba" )
    , ( "oboe", "oboe" )
    , ( "sitar", "sitar" )
    , ( "vibraphone", "vibraphone" )
    , ( "xylophone", "xylophone" )
    ]


instrumentMap : Dict String String
instrumentMap =
    fromList instruments


init : ( Model, Cmd Msg )
init =
    let
        ( webMidi, webMidiCmd ) =
            WebMidi.init
    in
        { audioContext = Nothing
        , fontsLoaded = False
        , instrument = "acoustic_grand_piano"
        , webMidi = webMidi
        }
            ! [ Cmd.map MidiMsg webMidiCmd
              , initialiseAudioContext ()
              ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SoundFontMsg soundFontMsg ->
            case soundFontMsg of
                ResponseAudioContext context ->
                    ( { model | audioContext = Just context }
                    , requestLoadRemoteFonts model.instrument
                    )

                ResponseFontsLoaded loaded ->
                    ( { model | fontsLoaded = loaded }
                    , initialiseWebMidi ()
                    )

                -- ignore any other messages
                _ ->
                    ( model, Cmd.none )

        MidiMsg midiMsg ->
            case midiMsg of
                Event _ _ midiEvent ->
                    ( model
                    , playNote midiEvent model
                    )

                -- route any other messages to the WebMid module
                _ ->
                    let
                        ( newWebMidi, cmd ) =
                            WebMidi.update midiMsg model.webMidi
                    in
                        { model | webMidi = newWebMidi } ! [ Cmd.map MidiMsg cmd ]

        ChangeInstrument instrument ->
            let
                gleitzName =
                    Dict.get instrument instrumentMap
                        |> withDefault "acoustic_grand_piano"
            in
                ( { model | fontsLoaded = False, instrument = instrument }
                  -- , requestLoadRemoteFonts "acoustic_grand_piano"
                , requestLoadRemoteFonts gleitzName
                )


{-| just respond to NoteOn events by playing them

  Copy-pasted from Piano.  We should break out into a separate file
-}
playNote : Result String MidiEvent -> Model -> Cmd Msg
playNote event model =
    case event of
        Ok midiEvent ->
            case midiEvent of
                NoteOn channel pitch velocity ->
                    let
                        -- this is the utter maximum velocity
                        volumeCeiling =
                            127.0

                        -- this is the fraction that it is scaled back by the volume control
                        volumeScale =
                            Basics.toFloat model.webMidi.maxVolume / volumeCeiling

                        -- and this is what's left of the note
                        gain =
                            Basics.toFloat velocity * volumeScale / volumeCeiling

                        note =
                            -- MidiNote
                            { id = pitch, timeOffset = 0.0, gain = gain }

                        -- _ =  log "gain" gain
                    in
                        requestPlayNote note

                _ ->
                    Cmd.none

        Err msg ->
            let
                _ =
                    log "note error" msg
            in
                Cmd.none


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map MidiMsg (WebMidi.subscriptions model.webMidi)
        , Sub.map SoundFontMsg audioContextSub
        , Sub.map SoundFontMsg fontsLoadedSub
        ]


viewAudioContext : Model -> String
viewAudioContext model =
    case model.audioContext of
        Just context ->
            "Audio Context got"

        _ ->
            "No Audio Context yet"


initialisationStatus : Model -> String
initialisationStatus model =
    case model.audioContext of
        Just context ->
            if model.fontsLoaded then
                "Ready to play"
            else
                "SoundFonts not loaded"

        _ ->
            "No Audio Context"


instrumentMenu : Model -> Html Msg
instrumentMenu model =
    select
        [ selectionStyle
        , on "change"
            (Json.map ChangeInstrument targetValue)
        ]
        (instrumentOptions model.instrument)


selectedInstrument : String -> String -> Attribute Msg
selectedInstrument target pattern =
    selected (target == pattern)



{- build the drop down list of instruments using the gleitz soundfont instrument name -}


instrumentOptions : String -> List (Html Msg)
instrumentOptions name =
    let
        f ( instrument, gleitzName ) =
            option [ selectedInstrument name instrument ]
                [ text instrument ]
    in
        List.map f instruments


view : Model -> Html Msg
view model =
    div []
        [ -- p [] [ text ("instrument: " ++ model.instrument) ]
          p [] [ text (initialisationStatus model) ]
        , span [] [ text "select an instrument" ]
        , instrumentMenu model
        ]


selectionStyle : Attribute msg
selectionStyle =
    style
        [ ( "margin-left", "40px" )
        , ( "margin-top", "20px" )
        , ( "font-size", "1em" )
        ]
