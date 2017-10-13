"use strict";

myapp.ports.initialiseWebMidi.subscribe(webMidiConnect);


function webMidiConnect () {

   console.log('MIDIConnect');
   // request MIDI access and then connect
   if (navigator.requestMIDIAccess) {
      myapp.ports.initialised.send(true);
   }
   else {
      myapp.ports.initialised.send(false);
   }
 }

myapp.ports.requestDevices.subscribe(detectDevices);


function detectDevices () {

   console.log('MIDIConnect');
   // request MIDI access and then connect
   if (navigator.requestMIDIAccess) {
      navigator.requestMIDIAccess({
        sysex: false // this defaults to 'false' anyway.
      }).then(onMIDISuccess)
   }
}

 // Set up all the signals we expect if MIDI is supported
function onMIDISuccess(midiAccess) {
     // console.log('MIDI Access Object', midiAccess);

     var inputs = midiAccess.inputs.values();
     // loop over any register inputs and listen for data on each
     midiAccess.inputs.forEach( function( input, id, inputMap ) {
       registerInput(input);
       input.onmidimessage = onMIDIMessage;
     });

     var outputs = midiAccess.outputs.values();
     // loop over any register inputs and listen for data on each
     midiAccess.outputs.forEach( function( output, id, outputMap ) {
       registerOutput(output);
       output.onmidimessage = onMIDIMessage;
     });

     // listen for connect/disconnect message
     midiAccess.onstatechange = onStateChange;
}

// register an input device
function registerInput(input){
     /* */
     console.log("Input port : [ type:'" + input.type + "' id: '" + input.id +
        "' manufacturer: '" + input.manufacturer + "' name: '" + input.name +
        "' version: '" + input.version + "']");
     /* */
     var midiConnection = { portType : input.type
                          , id : input.id
                          , manufacturer : input.manufacturer
                          , name : input.name
                          , version : input.version };

     myapp.ports.inputDevice.send(midiConnection);
}

// register an output device
function registerOutput(output){
     /* */
     console.log("output port : [ type:'" + output.type + "' id: '" + output.id +
        "' manufacturer: '" + output.manufacturer + "' name: '" + output.name +
        "' version: '" + output.version + "']");
     /* */
     var midiConnection = { portType : output.type
                          , id : output.id
                          , manufacturer : output.manufacturer
                          , name : output.name
                          , version : output.version };

     myapp.ports.outputDevice.send(midiConnection);
}

// input connect/disconnect signal
function onStateChange(event){
    // showMIDIPorts(midi);
    var port = event.port, state = port.state, name = port.name, type = port.type, id = port.id;
    if (port.type == "input") {
        console.log("State change:", state);
        if (state == "connected") {
             var midiConnection = { portType : port.type
                                  , id : port.id
                                  , manufacturer : port.manufacturer
                                  , name : port.name
                                  , version : port.version };

          myapp.ports.inputDevice.send(midiConnection);
          port.onmidimessage = onMIDIMessage;
        }
        else if  (state == "disconnected") {
          var midiDisconnection = { portType : port.type
                                  , id : port.id };

          myapp.ports.inputDisconnected.send(midiDisconnection);
        }
    }
    else if (port.type == "output") {
        if (state == "connected") {
             var midiConnection = { portType : port.type
                                  , id : port.id
                                  , manufacturer : port.manufacturer
                                  , name : port.name
                                  , version : port.version };

             myapp.ports.outputDevice.send(midiConnection);
        }
        else if  (state == "disconnected") {
          var midiDisconnection = { portType : port.type
                                  , id : port.id };

          myapp.ports.outputDisconnected.send(midiDisconnection);
        }
    }
}

// MIDI message signal
function onMIDIMessage(event){
    // sourceId = event.srcElement.id;
    // console.log("MIDI Message");
    var encodedEvent = { timeStamp : event.timeStamp
                       , encodedBinary : encodeAsString(event.data)};
    myapp.ports.encodedEvent.send(encodedEvent);
}


function encodeAsString (data) {
  var dataLength = data.length;
  var encoded = "";
  for (var i = 0; i < dataLength; i++) {
    encoded += String.fromCharCode(data[i]);
  }
  return encoded;
}
