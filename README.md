elm-webmidi-ports
=================

This is an Elm 0.18 pseudo-library for [Web-MIDI](http://www.w3.org/TR/webmidi/).  It is an almost direct translation from [elm-webmidi](https://github.com/newlandsvalley/elm-webmidi) (elm 0.16) which was deprecated a year or so ago because it made heavy use of signals which suddenly vanished from the language.  The analogue of signals in Elm 0.18 is subscriptions which act through ports.  However, one downside of ports is that their use precludes publication in the Elm package repository.

This version has one advantage over its predecessor - MIDI Event messages are now properly parsed using the [elm-comidi](https://github.com/newlandsvalley/elm-comidi) parser which means that the full range of such messages is now supported.

Examples
--------

The examples directory holds sample programs.  At the moment there is just one - __basic.html__.  To build, cd to the examples directory and invoke __compile.sh__.  You will need to attach a MIDI input device to your computer to see any effect. At the time of writing, only Chrome has full support for web-midi - other browsers will fail to initialise or fail to respond (say) to key presses on a MIDI keyboard.

Dependencies
------------

      elm-lang/core 5.1.1
      elm-lang/html 2.0.0
      newlandsvalley/elm-comidi 2.2.0