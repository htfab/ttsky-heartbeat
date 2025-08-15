## How it works

The design is a smoke test for trying out a new process or standard cell library
in a setting where we only have access to a very limited number of pins.
In particular, it only uses the clock input and a single digital output.

## How to test

Supply a clock signal at any frequency and observe the test signal on `uo[0]`.

At a first glance we should see that the output signal changes every 1 or 2 ticks.

After decoding the Manchester-encoded signal we should see consecutive values from
an 8-bit counter in MSB format. Since there is no reset, the circuit powers up in
a random position of the output sequence, but we can either:
- wait for a sequence of 15 zeroes (Manchester-encoded, so 010101... for 30 ticks)
  which should definitely happen within 4096 ticks, and start decoding from there.
- find a start point within a 32-tick window where reading two 8-bit MSB values
  gives an increase of 1, and start reading from there.

The testbench gives an example for the second approach and should be easy to port
to Micropython for bring-up.

## External hardware

None
