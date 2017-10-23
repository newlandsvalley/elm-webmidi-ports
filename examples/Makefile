all: basicExample midiInstrumentExample pianoExample sendExample

basicExample: distjs/elmBasic.js
distjs/elmBasic.js: src/basic/Basic.elm
	elm-make src/basic/Basic.elm --output distjs/elmBasic.js

midiInstrumentExample: distjs/elmMidiInstrument.js
distjs/elmMidiInstrument.js: src/midiInstrument/MidiInstrument.elm
	elm-make src/midiInstrument/MidiInstrument.elm --output distjs/elmMidiInstrument.js

pianoExample: distjs/elmPiano.js
distjs/elmPiano.js: src/piano/Piano.elm
	elm-make src/piano/Piano.elm --output distjs/elmPiano.js

sendExample: distjs/elmSend.js
distjs/elmSend.js: src/send/Send.elm
	elm-make src/send/Send.elm --output distjs/elmSend.js

clean:
	rm distjs/*.js

format:
	elm-format src/
