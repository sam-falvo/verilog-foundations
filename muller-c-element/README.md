A [2-input Muller C-element](https://en.wikipedia.org/wiki/C-element) gate
functions very much like an AND-gate but with some input hysteresis.
For this reason, it's also sometimes called a Hysteresis Gate too.

It is basically a latch that, when the output is 0, is set only when the inputs are both 1.
Likewise, when the output is 1, it is reset only when the inputs are both 0.

|A|B|X|
|:-:|:-:|:-:|
|0|0|0|
|0|1|X|
|1|0|X|
|1|1|1|

This gate is often used for coordination tasks in asynchronous logic circuits.
For example,
an asynchronous pipeline can be constructed using these gates in a configuration like the following:

            +---+
    d0 o----|   |           +---+
            | C |-----*-----|   |           +---+
         +--|   |     |     | C |-----*-----|   |
         |  +---+     |  +--|   |     |     | C |----*--> q0
         |            |  |  +---+     |  +--|   |    |
         |            |  |            |  |  +---+    |
         |            |  |   +----+   |  |           |
         +------------|--|--o| =1 |---+  +-----------|--< ack
                      |  |   +----+                  |
                      |  |              +----+       |
        ack <---------+  +-------------o| =1 |-------+
                                        +----+
      \____  ______/  \_______  ______/ \_________  _____...
           \/                 \/                  \/
       Stage N-1            Stage N            Stage N+1

This circuit took me quite a bit of time to feel comfortable with,
but I think I finally understand it now.

Let `d0` and `q0` represent a "data valid" signal of some kind.
Each stage is shown without any kind of data processing of any kind for simplicity.

We first assume all outputs are low (except for inverters, which are high).
When `d0` is asserted, C(n-1) output goes high as well (since A, B = 1, 1).
This causes C(n) to go high almost right away.
Its inverter causes C(n-1) to latch in the high state until `d0` is brought low again.
(The assertion of `ack` could be a trigger for this to happen.)
When it does, stage N-1 is once again in a quiescent state, ready for another batch of processing.
Meanwhile, this cycle repeats between stages N and N+1.

What happens with `q0` though?
Presumably this has to terminate at some kind of (potentially synchronous) endpoint function.
When `q0` goes high, the function is notified that data exists and is ready for processing.
However, it might not assert `ack` right away (in fact, we expect it not to).
Because `ack` remains *high* in this case (remember the need for the inverters!),
`q0` will remain asserted.
This is because the unnamed feedback on C(n) is *low*, which potentially brings its output low as a result.
C(n+1) will have A, B = 0, 1 for inputs, which latches `q0` high!
It will not reset until the endpoint brings `ack` low, thus completing the consumption of the input.

Like I said, this is subtle.  But, it's very clever!

## muller\_c signals

|Signal|Direction|Purpose|
|`a`|In|First of two inputs.|
|`b`|In|Second of two inputs.|
|`r`|In|Reset.  If asserted, regardless of the status of `a` or `b`, the output is driven low.|
|`x`|Out|1 if both `a` and `b` are 1, 0 if both `a` and `b` are 0; otherwise, retains last set value.|

The `r` input exists mainly to benefit synthesis and simulation tools.
On anything other than an FPGA, it's not likely that you'd ever need this signal.

