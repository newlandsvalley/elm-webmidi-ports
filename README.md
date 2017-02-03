elm-webmidi-ports
=================

This is an Elm 0.18 pseudo-library for [Web-MIDI](http://www.w3.org/TR/webmidi/).  It started life as an almost direct translation from [elm-webmidi](https://github.com/newlandsvalley/elm-webmidi) (elm 0.16) which was deprecated a year or so ago because it made heavy use of signals which suddenly vanished from the language.  The analogue of signals in Elm 0.18 is subscriptions which act through ports.  However, one downside of ports is that their use precludes publication in the Elm package repository.

This version has one advantage over its predecessor - MIDI Event messages are now properly parsed using the [elm-comidi](https://github.com/newlandsvalley/elm-comidi) parser which means that the full range of such messages is now supported.

The only processing that is done on the message stream is to recognise volume control messages and thus to save to state the current maximum volume.  This allows programs that use the module to respond to the volume control as notes are played.

You will need to attach a MIDI input device to your computer to see any effect from Web-MIDI. At the time of writing, Chrome has the best support. Recent versions of Opera and Firefox support it but playback seems unresponsive. Other browsers will fail to initialise or fail to respond (say) to key presses on a MIDI keyboard.

To build, invoke __compile.sh__ and browse to __webmidi.html__

Testing
-------

This project has been tested using an M-Audio KeystationMini32 keyboard.

Examples
--------

cd to the examples directory to see the sample programs.  

### Basic

[Basic.elm](https://github.com/newlandsvalley/elm-webmidi-ports/blob/master/examples/src/basic/Basic.elm) is functionally identical to WebMidi.elm.  It simply illustrates how you might embed the WebMidi module inside a larger program (but in this case this program does nothing else).

To build, invoke __compileb.sh__ and browse to __basic.html__.

### Piano

[Piano.elm](https://github.com/newlandsvalley/elm-webmidi-ports/blob/master/examples/src/piano/Piano.elm) allows you to plug in your MIDI keyboard or other MIDI device and play it as a piano. It works simply by loading the piano soundfont which is served as a local resource, initialising web-midi and requesting that any NoteOn events should be played through the soundfont.

To build, invoke __compilep.sh__ and browse to __piano.html__.

### Pick an Instrument

[MidiInstrument.elm](https://github.com/newlandsvalley/elm-webmidi-ports/tree/master/examples/src/midiInstrument/MidiInstrument.elm) allows you to plug in your MIDI keyboard or other MIDI device and to choose the instrumental sound it makes. In this case, the soundfonts are loaded directly from Benjamin Gleitzman's github package of [pre-rendered sound fonts](https://github.com/gleitz/midi-js-soundfonts). These may take a little longer to load.

To build, invoke __compilemi.sh__ and browse to __midiInstrument.html__.

Limitations
-----------

At the moment, no attempt is made to discriminate between channels.  i.e. it is intended for use when only a single MIDI device is plugged in.  Also, no attempt is made to respond to NoteOff messages.  Each note is allowed to 'ring' for its natural duration, which will depend on the type of instrument being emulated by the soundfont.

Suggestions for Further Work
----------------------------

This would be the basis of an ideal component for anyone wishing to write a web-audio synthesiser in elm which might respond to a larger selection of control messages.

Dependencies
------------

      elm-lang/core 5.1.1
      elm-lang/html 2.0.0
      newlandsvalley/elm-comidi 2.2.0