#include <cstdint>
#include <iomanip>
#include <iostream>
#include <string>

#ifndef UART_SYSTEM_HEADER
#define UART_SYSTEM_HEADER "uart_system.h"
#endif
#include UART_SYSTEM_HEADER

using cxxrtl_design::p_uart__system__tb;

static void tick(p_uart__system__tb &top) {
    top.p_clk.set(false);
    top.step();
    top.p_clk.set(true);
    top.step();
}

int main() {
    p_uart__system__tb top;
    top.p_clk.set(false);
    top.p_rst.set(true);
    top.step();
    for (int cycle = 0; cycle < 5; ++cycle)
        tick(top);
    top.p_rst.set(false);

    constexpr uint32_t clocks_per_bit = 50'000'000 / 115'200;
    bool receiving = false;
    bool waiting_for_stop = false;
    uint32_t sample_countdown = 0;
    uint32_t bit_index = 0;
    uint8_t byte = 0;
    std::string serial;
    uint32_t previous_led = 0xffffffffu;
    bool saw_mext_pass = false;

    for (uint32_t cycle = 0; cycle < 800'000; ++cycle) {
        tick(top);

        const uint32_t led = top.p_observed__led.get<uint32_t>();
        if (led != previous_led) {
            std::cout << "cycle " << cycle << " LED=0x" << std::hex
                      << std::setw(4) << std::setfill('0') << led << std::dec
                      << "\n";
            previous_led = led;
            if ((led & 0xff00u) == 0x8000u) {
                std::cerr << "FAIL: M-extension error marker 0x"
                          << std::hex << led << "\n";
                return 1;
            }
            if (led == 0x00a5u)
                saw_mext_pass = true;
        }

        const bool tx = top.p_observed__tx.get<bool>();
        if (!receiving && !waiting_for_stop) {
            if (!tx) {
                receiving = true;
                sample_countdown = clocks_per_bit + clocks_per_bit / 2;
                bit_index = 0;
                byte = 0;
            }
        } else if (receiving) {
            if (sample_countdown == 0) {
                if (tx)
                    byte |= static_cast<uint8_t>(1u << bit_index);
                ++bit_index;
                if (bit_index == 8) {
                    serial.push_back(static_cast<char>(byte));
                    receiving = false;
                    waiting_for_stop = true;
                    sample_countdown = clocks_per_bit;
                } else {
                    sample_countdown = clocks_per_bit - 1;
                }
            } else {
                --sample_countdown;
            }
        } else if (sample_countdown == 0) {
            waiting_for_stop = false;
        } else {
            --sample_countdown;
        }
    }

    std::cout << "SERIAL BEGIN\n" << serial << "\nSERIAL END\n";

    const uint32_t final_led = top.p_observed__led.get<uint32_t>();
    const bool final_rx_valid = top.p_observed__rx__valid.get<bool>();
    const char *required_text[] = {
        "miniRV Pipeline AXI EGO1 Test",
        "<Phase 0> M-extension self-test: PASS",
        "<Phase 1> UART input test",
        "Enter a char:",
        "Input received: A",
        "Test ended."
    };

    if (!saw_mext_pass) {
        std::cerr << "FAIL: M-extension PASS marker was not reached\n";
        return 2;
    }
    if (final_led != 0x0041u || final_rx_valid) {
        std::cerr << "FAIL: UART acceptance did not finish LED=0x"
                  << std::hex << final_led << " RX_VALID=" << final_rx_valid
                  << "\n";
        return 3;
    }
    for (const char *text : required_text) {
        if (serial.find(text) == std::string::npos) {
            std::cerr << "FAIL: serial output missing: " << text << "\n";
            return 4;
        }
    }

    std::cout << "PASS: formal pipeline/M-extension/UART acceptance\n";
    return 0;
}
