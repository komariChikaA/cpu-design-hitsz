#include <stddef.h>

extern unsigned char _heap_start;
extern unsigned char _stack_top;

static unsigned char *heap_next = &_heap_start;
static unsigned char *last_allocation;
static unsigned char *last_heap_start;

void *malloc(size_t size)
{
    const size_t alignment = 8;
    const size_t stack_guard = 2048;
    unsigned char *heap_limit = &_stack_top - stack_guard;

    if (size == 0 || size > (size_t)(heap_limit - heap_next))
        return 0;

    size = (size + alignment - 1) & ~(alignment - 1);
    if (size > (size_t)(heap_limit - heap_next))
        return 0;

    last_heap_start = heap_next;
    void *result = heap_next;
    heap_next += size;
    last_allocation = result;
    return result;
}

void free(void *ptr)
{
    /*
     * C_TEST2 has one live allocation.  Reclaim the most recent allocation so
     * its malloc/free pair has real release semantics without requiring newlib.
     */
    if (ptr != 0 && ptr == last_allocation)
    {
        heap_next = last_heap_start;
        last_allocation = 0;
        last_heap_start = 0;
    }
}

void *memset(void *dest, int value, size_t count)
{
    unsigned char *bytes = (unsigned char *)dest;
    while (count-- != 0)
        *bytes++ = (unsigned char)value;
    return dest;
}
