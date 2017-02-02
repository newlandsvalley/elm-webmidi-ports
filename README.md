elm-webmidi-ports
=================

This is an Elm 0.18 pseudo-library for [Web-MIDI](http://www.w3.org/TR/webmidi/).  It is an almost direct translation from [elm-webmidi](https://github.com/newlandsvalley/elm-webmidi) (elm 0.16) which was deprecated a year or so ago because it made heavy use of signals which suddenly vanished from the language.  The analogue of signals in Elm 0.18 is subscriptions which act through ports.  However, one downside of ports is that their use precludes publication in the Elm package repository.

This version has one advantage over its predecessor - MIDI Event messages are now properly parsed using the [elm-comidi](https://github.com/newlandsvalley/elm-comidi) parser which means that the full range of such messages is now supported.

You will need to attach a MIDI input device to your computer to see any effect from Web-MIDI. At the time of writing, Chrome has the best support. Recent versions of Opera and Firefox support it but playback seems unresponsive. Other browsers will fail to initialise or fail to respond (say) to key presses on a MIDI keyboard.

To build, invoke __compile.sh__ and browse to __webmidi.html__

Examples
--------

cd to the examples directory to see the sample programs.  

### Basic

basic.html is functionally identical to webmidi.html.  It simply illustrates how you might embed the WebMidi module inside a larger program (but in this case this program does nothing else).

To build, invoke __compileb.sh__ and browse to __basic.html__.

### Piano

piano.html allows you to plug in your MIDI keyboard or other MIDI device and play it as a piano. It works simply by loading the piano soundfont, initialising web-midi and requesting that any NoteOn events should be played through the soundfont.

To build, invoke __compilep.sh__ and browse to __piano.html__.


Dependencies
------------

      elm-lang/core 5.1.1
      elm-lang/html 2.0.0
      newlandsvalley/elm-comidi 2.2.0