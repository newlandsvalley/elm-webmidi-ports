module Basic exposing (..)

import Html exposing (Html, Attribute, map, div)
import WebMidi exposing (Model, init, update, view, subscriptions)
import WebMidi.Msg exposing (..)


{- This program simply illustrates how you might embed the WebMidi
   module inside a master program.  It is 'do nothing' - simply
   deferring to WebMidi is all cases.

   The key issue is that it seems to be impossible for a module to
   re-export its Msg type and so each of the module and the calling
   program imports this type independently.
-}


main =
    Html.program
        { init = init, update = update, view = view, subscriptions = subscriptions }


type Msg
    = MidiMsg WebMidi.Msg.Msg


type alias Model =
    { webMidi : WebMidi.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        ( webMidi, webMidiCmd ) =
            WebMidi.init
    in
        { webMidi = webMidi
        }
            ! [ Cmd.map MidiMsg webMidiCmd ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MidiMsg midiMsg ->
            let
                ( newWebMidi, cmd ) =
                    WebMidi.update midiMsg model.webMidi
            in
                { model | webMidi = newWebMidi } ! [ Cmd.map MidiMsg cmd ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map MidiMsg (WebMidi.subscriptions model.webMidi)
        ]


view : Model -> Html Msg
view model =
    div []
        [ Html.map MidiMsg (WebMidi.view model.webMidi)
        ]
