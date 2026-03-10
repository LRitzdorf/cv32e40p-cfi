#include <stdio.h>
#include <stdlib.h>

static int add(int a, int b) { return a + b; }
static int sub(int a, int b) { return a - b; }
static int mul(int a, int b) { return a * b; }

typedef int (*binop_t)(int, int);

static volatile binop_t ops[] = { add, sub, mul };

int main(void)
{
    /* Enable zicfilp */
    __asm__ volatile("csrw 0x747, %0" :: "r"(1 << 2));

    int r = ((binop_t)ops[0])(10, 3);
    r = ((binop_t)ops[1])(r, 5);
    r = ((binop_t)ops[2])(r, 3);

    /* Disable before returning to non-CFI library code */
    __asm__ volatile("csrw 0x747, %0" :: "r"(0));

    printf("Result: %d\n", r);
    return EXIT_SUCCESS;
}