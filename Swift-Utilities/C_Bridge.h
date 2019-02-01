//
//  C_Bridge.h
//  Swift-Utilities
//
//  Created by tridiak on 14/11/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

#ifndef C_Bridge_h
#define C_Bridge_h

#include <stdio.h>

typedef struct CPath {
	char path[1024];
} CPath;

int GetPathForDesc(int desc, CPath* buffer);
uint16_t B16(void* blob, uint64_t idx);

#endif /* C_Bridge_h */
