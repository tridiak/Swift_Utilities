//
//  C_Bridge.c
//  Swift-Utilities
//
//  Created by tridiak on 14/11/18.
//  Copyright © 2018 tridiak. All rights reserved.
//

#include "C_Bridge.h"
#include <string.h>
#include <fcntl.h>

int GetPathForDesc(int desc, CPath* buffer) {
	if (!buffer) { return -1; }
	bzero(buffer->path, 1024);
	return fcntl(desc, F_GETPATH, buffer->path);
};

uint16_t B16(void* blob, uint64_t idx) {
	uint8_t* ptr = (uint8_t*)blob;
	uint16_t* ptr16 = (uint16*)(ptr + idx);
	
	return *ptr16;
}
