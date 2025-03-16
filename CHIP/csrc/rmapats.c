// file = 0; split type = patterns; threshold = 100000; total count = 0.
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

void  hsG_0__0 (struct dummyq_struct * I1393, EBLK  * I1388, U  I619);
void  hsG_0__0 (struct dummyq_struct * I1393, EBLK  * I1388, U  I619)
{
    U  I1656;
    U  I1657;
    U  I1658;
    struct futq * I1659;
    struct dummyq_struct * pQ = I1393;
    I1656 = ((U )vcs_clocks) + I619;
    I1658 = I1656 & ((1 << fHashTableSize) - 1);
    I1388->I665 = (EBLK  *)(-1);
    I1388->I666 = I1656;
    if (0 && rmaProfEvtProp) {
        vcs_simpSetEBlkEvtID(I1388);
    }
    if (I1656 < (U )vcs_clocks) {
        I1657 = ((U  *)&vcs_clocks)[1];
        sched_millenium(pQ, I1388, I1657 + 1, I1656);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I619 == 1)) {
        I1388->I668 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I665 = I1388;
        peblkFutQ1Tail = I1388;
    }
    else if ((I1659 = pQ->I1296[I1658].I688)) {
        I1388->I668 = (struct eblk *)I1659->I686;
        I1659->I686->I665 = (RP )I1388;
        I1659->I686 = (RmaEblk  *)I1388;
    }
    else {
        sched_hsopt(pQ, I1388, I1656);
    }
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
