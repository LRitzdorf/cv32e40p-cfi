#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    // Execute several MOPs
    {
        // MOP.R.n
        unsigned int mop0, mop7, mop31;
        __asm__ volatile("mop.r.0  %0, %1" : "=r"(mop0)  : "r"(0));
        __asm__ volatile("mop.r.7  %0, %1" : "=r"(mop7)  : "r"(0));
        __asm__ volatile("mop.r.31 %0, %1" : "=r"(mop31) : "r"(0));
        printf("mop.r.0  result: %u\n", mop0);
        printf("mop.r.7  result: %u\n", mop7);
        printf("mop.r.31 result: %u\n", mop31);
    }
    {
        // MOP.RR.n
        unsigned int mop0, mop3, mop7;
        __asm__ volatile("mop.rr.0 %0, %1, %2" : "=r"(mop0) : "r"(0), "r"(0));
        __asm__ volatile("mop.rr.3 %0, %1, %2" : "=r"(mop3) : "r"(0), "r"(0));
        __asm__ volatile("mop.rr.7 %0, %1, %2" : "=r"(mop7) : "r"(0), "r"(0));
        printf("mop.rr.0 result: %u\n", mop0);
        printf("mop.rr.3 result: %u\n", mop3);
        printf("mop.rr.7 result: %u\n", mop7);
    }

    // Execute several compressed MOPs
    {
        // NOTE: "memory" as a clobber here prevents optimizing these away
        __asm__ volatile("c.mop.1"  ::: "memory");
        __asm__ volatile("c.mop.5"  ::: "memory");
        __asm__ volatile("c.mop.15" ::: "memory");
    }

    return EXIT_SUCCESS;
}
