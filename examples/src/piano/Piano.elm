module Piano exposing (..)

import Html exposing (Html, Attribute, map, div, p, text)
import WebMidi exposing (Model, init, update, subscriptions)
import WebMidi.Msg exposing (..)
import WebMidi.Ports exposing (initialiseWebMidi)
import WebMidi.Subscriptions exposing (eventSub)
import Midi.Types exposing (MidiEvent(..))
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


type alias Model =
    { audioContext : Maybe AudioContext
    , fontsLoaded : Bool
    , webMidi : WebMidi.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( webMidi, webMidiCmd ) =
            WebMidi.init
    in
        { audioContext = Nothing
        , fontsLoaded = False
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
                    , requestLoadPianoFonts "soundfonts"
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



{- just respond to NoteOn events by playing them -}


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


view : Model -> Html Msg
view model =
    div []
        [ p [] [ text (initialisationStatus model) ]
        ]
