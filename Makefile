all: webmidi examples

webmidi: distjs/elmWebMidi.js

distjs/elmWebMidi.js: src/WebMidi.elm src/WebMidi/*.elm
	elm-make src/WebMidi.elm --output distjs/elmWebMidi.js

.PHONY: examples
examples:
	$(MAKE) -C examples all

clean:
	rm distjs/*.js
	$(MAKE) -C examples clean
