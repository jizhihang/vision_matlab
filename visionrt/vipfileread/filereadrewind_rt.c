/*
* FILEREADREWIND_RT runtime function for VIPBLKS Read Binary File block
*
*  Copyright 1995-2007 The MathWorks, Inc.
*/
#include "vipfileread_rt.h"
#include <stdio.h>

LIBMWVISIONRT_API void MWVIP_FileReadRewind(void *fptrDW)
{
    FILE **fptr = (FILE **) fptrDW;
	if (fptr[0] != NULL)
       rewind(fptr[0]);
}

/* [EOF] filereadrewind_rt.c */