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

myapp.ports.sendMidiAll.subscribe(sendMidiAllPlaceholder);

function sendMidiAllPlaceholder (bytes) {
   console.warn('sendMidiAll error: No midi access yet.')
}


// Set up all the signals we expect if MIDI is supported
function onMIDISuccess(midiAccess) {
     // console.log('MIDI Access Object', midiAccess);

     var inputs = midiAccess.inputs.values();
     // loop over any register inputs and listen for data on each
     midiAccess.inputs.forEach( function( input, id, inputMap ) {
       registerInput(input);
       input.onmidimessage = onMIDIMessage.bind(null, id);
     });

     var outputs = midiAccess.outputs.values();
     // loop over any register outputs
     midiAccess.outputs.forEach( function( output, id, outputMap ) {
       registerOutput(output);
     });

     // listen for connect/disconnect message
     midiAccess.onstatechange = onStateChange;

     // define sendMidiAll to use midiAccess
     function sendMidiAll (bytes) {
         var realBytes = new Uint8Array(bytes);
         console.log('sendMidiAll: ', realBytes);
         midiAccess.outputs.forEach( function( port, key ) {
             port.send(bytes);
         });
     }
     // point sendMidiAll to the new function
     myapp.ports.sendMidiAll.subscribe(sendMidiAll);
     myapp.ports.sendMidiAll.unsubscribe(sendMidiAllPlaceholder);
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
          port.onmidimessage = onMIDIMessage.bind(null, port.id);
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
function onMIDIMessage(id, event){
    // sourceId = event.srcElement.id;
    // console.log("MIDI Message");
    var encodedEvent = { id : id
                       , timeStamp : event.timeStamp
                       , encodedBinary : encodeAsString(event.data)
                       };
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
