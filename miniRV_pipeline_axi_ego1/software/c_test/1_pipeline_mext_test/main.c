#define SW_BASE   0xFFFF0000
#define LED_BASE  0xFFFF1000
#define DLED_BASE 0xFFFF2000
#define UART_BASE 0xFFFF3000

typedef unsigned int u32;
typedef signed int s32;

volatile u32 *peri_sw     = (volatile u32 *)SW_BASE;
volatile u32 *peri_led    = (volatile u32 *)LED_BASE;
volatile u32 *peri_digled = (volatile u32 *)DLED_BASE;
volatile u32 *uart_rx_fifo  = (volatile u32 *)UART_BASE;
volatile u32 *uart_tx_fifo  = (volatile u32 *)(UART_BASE + 0x4);
volatile u32 *uart_stat_reg = (volatile u32 *)(UART_BASE + 0x8);
volatile u32 *uart_ctrl_reg = (volatile u32 *)(UART_BASE + 0xC);

static void uart_init(void)
{
    *uart_ctrl_reg = 0x3;
}

static void uart_putc(char c)
{
    while (*uart_stat_reg & 0x8);
    *uart_tx_fifo = (u32)c;
}

static char uart_getc(void)
{
    while (!(*uart_stat_reg & 0x1));
    return (char)*uart_rx_fifo;
}

static void print_str(const char *str)
{
    while (*str)
        uart_putc(*str++);
}

static u32 rv_mul(u32 a, u32 b)
{
    u32 result;
    __asm__ volatile ("mul %0, %1, %2" : "=r"(result) : "r"(a), "r"(b));
    return result;
}

static s32 rv_mulh(s32 a, s32 b)
{
    s32 result;
    __asm__ volatile ("mulh %0, %1, %2" : "=r"(result) : "r"(a), "r"(b));
    return result;
}

static u32 rv_mulhu(u32 a, u32 b)
{
    u32 result;
    __asm__ volatile ("mulhu %0, %1, %2" : "=r"(result) : "r"(a), "r"(b));
    return result;
}

static s32 rv_div(s32 a, s32 b)
{
    s32 result;
    __asm__ volatile ("div %0, %1, %2" : "=r"(result) : "r"(a), "r"(b));
    return result;
}

static u32 rv_divu(u32 a, u32 b)
{
    u32 result;
    __asm__ volatile ("divu %0, %1, %2" : "=r"(result) : "r"(a), "r"(b));
    return result;
}

static s32 rv_rem(s32 a, s32 b)
{
    s32 result;
    __asm__ volatile ("rem %0, %1, %2" : "=r"(result) : "r"(a), "r"(b));
    return result;
}

static u32 rv_remu(u32 a, u32 b)
{
    u32 result;
    __asm__ volatile ("remu %0, %1, %2" : "=r"(result) : "r"(a), "r"(b));
    return result;
}

static u32 run_mext_self_test(void)
{
    volatile u32 six = 6;
    volatile u32 seven = 7;
    volatile u32 zero = 0;
    volatile u32 high_bit = 0x80000000u;
    volatile s32 minus_one = -1;

    if (rv_mul(six, seven) != 42u) return 1;
    if (rv_mulh(-2, 3) != -1) return 2;
    if (rv_mulhu(high_bit, 2u) != 1u) return 3;
    if (rv_div(-42, 6) != -7) return 4;
    if (rv_divu(42u, six) != 7u) return 5;
    if (rv_rem(-43, 6) != -1) return 6;
    if (rv_remu(43u, six) != 1u) return 7;
    if ((u32)rv_div((s32)six, (s32)zero) != 0xFFFFFFFFu) return 8;
    if (rv_divu(six, zero) != 0xFFFFFFFFu) return 9;
    if ((u32)rv_rem((s32)high_bit, (s32)zero) != high_bit) return 10;
    if (rv_remu(seven, zero) != seven) return 11;
    if ((u32)rv_div((s32)high_bit, minus_one) != high_bit) return 12;
    if (rv_rem((s32)high_bit, minus_one) != 0) return 13;
    return 0;
}

int main(void)
{
    uart_init();
    print_str("miniRV Pipeline AXI EGO1 Test\n\r");
    print_str("<Phase 0> M-extension self-test: ");

    u32 failure = run_mext_self_test();
    if (failure != 0) {
        *peri_led = 0x8000u | failure;
        *peri_digled = 0xE0000000u | failure;
        print_str("FAIL - see LED/display error code\n\r");
        while (1);
    }

    *peri_led = 0x00A5u;
    *peri_digled = 0x600D600Du;
    print_str("PASS\n\r");
    print_str("<Phase 1> UART input test\n\r");

    while (1) {
        print_str("Enter a char: ");
        char ch = uart_getc();
        print_str("Input received: ");
        uart_putc(ch);
        print_str("\n\r");

        *peri_led = (u32)ch;
        *peri_digled = (u32)ch;

        if (*peri_sw == 0) {
            print_str("Test ended.\n\r");
            break;
        }
    }

    return 0;
}
