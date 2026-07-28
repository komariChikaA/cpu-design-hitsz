#include <cstdint>
#include <iomanip>
#include <iostream>

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
    uint32_t previous_led = 0xffffffffu;
    bool previous_rx_valid = false;
    uint32_t mmio_reads = 0;

    for (uint32_t cycle = 0; cycle < 22'000; ++cycle) {
        tick(top);

        const uint32_t led = top.p_observed__led.get<uint32_t>();
        const bool rx_valid = top.p_observed__rx__valid.get<bool>();
        const uint32_t rx_data = top.p_observed__rx__data.get<uint32_t>();
        const uint32_t pc = top.p_observed__pc.get<uint32_t>();
        const uint32_t araddr = top.p_observed__araddr.get<uint32_t>();
        const uint32_t rdata = top.p_observed__rdata.get<uint32_t>();
        const bool arvalid = top.p_observed__arvalid.get<bool>();
        const bool rvalid = top.p_observed__rvalid.get<bool>();

        if (led != previous_led) {
            std::cout << "cycle " << cycle << " LED=0x"
                      << std::hex << std::setw(4) << std::setfill('0') << led
                      << " PC=0x" << std::setw(8) << pc << std::dec << "\n";
            previous_led = led;
        }

        if (rx_valid != previous_rx_valid) {
            std::cout << "cycle " << cycle << " rx_valid=" << rx_valid
                      << " rx_data=0x" << std::hex << std::setw(2)
                      << rx_data << std::dec << "\n";
            previous_rx_valid = rx_valid;
        }

        if (arvalid && araddr >= 0xffff0000u) {
            ++mmio_reads;
            if (mmio_reads <= 3 || (mmio_reads % 100) == 0) {
                std::cout << "cycle " << cycle << " MMIO[" << mmio_reads
                          << "] ARADDR=0x" << std::hex << std::setw(8)
                          << araddr << " PC=0x" << std::setw(8) << pc
                          << std::dec << "\n";
            }
        }

        if (rvalid && araddr >= 0xffff0000u &&
            (mmio_reads <= 3 || (mmio_reads % 100) == 0)) {
            std::cout << "cycle " << cycle << " MMIO RDATA=0x"
                      << std::hex << std::setw(8) << rdata
                      << " PC=0x" << std::setw(8) << pc << std::dec << "\n";
        }
    }

    const uint32_t final_led = top.p_observed__led.get<uint32_t>();
    const uint32_t final_rx_data = top.p_observed__rx__data.get<uint32_t>();
    const bool final_rx_valid = top.p_observed__rx__valid.get<bool>();
    const uint32_t final_pc = top.p_observed__pc.get<uint32_t>();

    std::cout << "FINAL LED=0x" << std::hex << std::setw(4) << final_led
              << " RX_DATA=0x" << std::setw(2) << final_rx_data
              << " RX_VALID=" << final_rx_valid
              << " PC=0x" << std::setw(8) << final_pc
              << std::dec << " MMIO_READ_CYCLES=" << mmio_reads << "\n";

    if (final_rx_data != 0x41u) {
        std::cerr << "FAIL: UART receiver did not capture 0x41\n";
        return 1;
    }
    if (final_led != 0x0041u) {
        std::cerr << "FAIL: CPU did not move received 0x41 to LED\n";
        return 2;
    }

    std::cout << "PASS: full UART CPU/AXI/MMIO path\n";
    return 0;
}
