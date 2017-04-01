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
I'll document how the circuit works later, as I need to head out of the office now.  :)

