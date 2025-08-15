from random import seed, randrange

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):

    try:
        # RTL test
        regs = ([dut.hb.counter[i] for i in range(8)] +
                [dut.hb.index[i] for i in range(3)] +
                [dut.hb.manchester, dut.hb.signal])
    except AttributeError:
        # GL test
        regs = ([dut.hb._id(rf"\counter[{i}]", extended=False) for i in range(8)] +
                [dut.hb._id(rf"\index[{i}]", extended=False) for i in range(3)] +
                [dut.hb.manchester, dut.hb.signal])

    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    for T in range(256):
        dut._log.info(f"Starting round {T}")

        for i in regs:
            i.value = randrange(2)

        await ClockCycles(dut.clk, 3)

        last = dut.uo_out[0].value
        seq1 = str(last)
        for i in range(32):
            await ClockCycles(dut.clk, 1)
            val = dut.uo_out[0].value
            seq1 += str(val)
            if val == last:
                break
            last = val
        else:
            dut._log.error(f"Unexpected sequence {seq1}")
            assert False

        val = 0
        seq2 = []
        for i in range(32):
            await ClockCycles(dut.clk, 2)
            val = ((val << 1) | dut.uo_out[0].value) & 0xff
            seq2.append(val)
            if i >= 15 and val == (seq2[-9] + 1) & 0xff:
                break
        else:
            dut._log.error(f"Unexpected sequence {seq1} {seq2[7:]}")
            assert False

        for i in range(256):
            last = val
            val = 0
            for i in range(8):
                await ClockCycles(dut.clk, 2)
                val = ((val << 1) | dut.uo_out[0].value) & 0xff
            if val != (last + 1) & 0xff:
                dut._log.error(f"Unexpected sequence {seq1} {seq2[7:]} .. {last} {val}")
                assert False

