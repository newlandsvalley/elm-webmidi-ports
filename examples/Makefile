all: basicExample midiInstrumentExample pianoExample sendExample

webmidi: ../src/WebMidi.elm ../src/WebMidi/*.elm

basicExample: distjs/elmBasic.js webmidi
distjs/elmBasic.js: src/basic/Basic.elm
	elm-make src/basic/Basic.elm --output distjs/elmBasic.js

midiInstrumentExample: distjs/elmMidiInstrument.js webmidi
distjs/elmMidiInstrument.js: src/midiInstrument/MidiInstrument.elm
	elm-make src/midiInstrument/MidiInstrument.elm --output distjs/elmMidiInstrument.js

pianoExample: distjs/elmPiano.js webmidi
distjs/elmPiano.js: src/piano/Piano.elm
	elm-make src/piano/Piano.elm --output distjs/elmPiano.js

sendExample: distjs/elmSend.js webmidi
distjs/elmSend.js: src/send/Send.elm
	elm-make src/send/Send.elm --output distjs/elmSend.js

clean:
	rm distjs/*.js

format:
	elm-format src/
