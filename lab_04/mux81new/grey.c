/*
 * Copyright 1991-2015 Mentor Graphics Corporation
 *
 * All Rights Reserved.
 *
 * THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE
 * PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO
 * LICENSE TERMS.
 *
 * Simple SystemVerilog DPI Example - C model 8-to-1 multiplexer
 */
#include "grey.h"

int grey (
    int select)
{
    switch (select) {
        case 0x0: return(0);
        case 0x1: return(1);
        case 0x2: return(3);
        case 0x3: return(2);
        case 0x4: return(6);
        case 0x5: return(7);
        case 0x6: return(5);
        case 0x7: return(4);
    }
    return 0;
}
