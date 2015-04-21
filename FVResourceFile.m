//
//  FVResourceFile.m
//  ForkView
//
//  Created by Kevin Wojniak on 5/25/11.
//  Copyright 2011 Kevin Wojniak. All rights reserved.
//

#import "FVResourceFile.h"
#import "FVResourceFilePriv.h"
#import "FVFork.h"
#import "ForkView-Swift.h"

@interface NSError (FVResource)

+ (NSError *)errorWithDescription:(NSString *)description;

@end

@implementation NSError (FVResource)

+ (NSError *)errorWithDescription:(NSString *)description
{
	return [NSError errorWithDomain:@"FVResourceErrorDomain" code:-1 userInfo:[NSDictionary dictionaryWithObject:description forKey:NSLocalizedFailureReasonErrorKey]];
}

@end

struct FVResourceHeader {
	uint32_t dataOffset;
	uint32_t mapOffset;
	uint32_t dataLength;
	uint32_t mapLength;
};

struct FVResourceMap {
	FVResourceHeader headerCopy;
	uint32_t nextMap;
	uint16_t fileRef;
	uint16_t attributes;
	uint16_t typesOffset;
	uint16_t namesOffset;
};

@interface FVResourceFile ()
- (BOOL)readHeader:(FVResourceHeader *)aHeader;
- (BOOL)readMap;
- (BOOL)readTypes;
@end

@implementation FVResourceFile

@synthesize types;

#pragma mark -
#pragma mark Public Methods

- (instancetype)initWithContentsOfURL:(NSURL *)fileURL error:(NSError **)error fork:(FVForkType)forkType
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	fork = [[FVFork alloc] initWithURL:fileURL type:forkType];
	if (!fork) {
		if (error) {
			*error = [NSError errorWithDescription:@"Bad file."];
		}
		return nil;
	}
	
	header = calloc(1, sizeof(FVResourceHeader));
	if ([self readHeader:header] == NO) {
		if (error) {
			*error = [NSError errorWithDescription:@"Invalid header."];
		}
		return nil;
	}
	
	//NSLog(@"HEADER (%u, %u), (%u, %u)", header->dataOffset, header->dataLength, header->mapOffset, header->mapLength);
	
	if ([self readMap] == NO) {
		if (error) {
			*error = [NSError errorWithDescription:@"Invalid map."];
		}
		return nil;
	}
	
	if ([self readTypes] == NO) {
		if (error) {
			*error = [NSError errorWithDescription:@"Invalid types list."];
		}
		return nil;
	}
	
	// Don't open empty (but valid) resource forks
	if (!types || ![types count]) {
		if (error) {
			*error = [NSError errorWithDescription:@"No resources."];
		}
		return nil;
	}
	
	return self;
}

- (instancetype)initWithContentsOfURL:(NSURL *)fileURL error:(NSError **)error
{
	NSError *tmpError = nil;
	FVResourceFile *file = [[[self class] alloc] initWithContentsOfURL:fileURL error:&tmpError fork:FVForkTypeResource];
	if (!file) {
		file = [[[self class] alloc] initWithContentsOfURL:fileURL error:&tmpError fork:FVForkTypeData];
	}
	if (file) {
		return file;
	}
	if (error) {
		*error = tmpError;
	}
	return nil;
}

+ (id)resourceFileWithContentsOfURL:(NSURL *)fileURL error:(NSError **)error
{
	return [(FVResourceFile*)[self alloc] initWithContentsOfURL:fileURL error:error];
}

#pragma mark -
#pragma mark Private Methods

- (void)dealloc
{
	if (header) {
		free(header);
	}
	if (map) {
		free(map);
	}
}

- (BOOL)readHeader:(FVResourceHeader *)aHeader
{
	// read the header values
	if (![fork read:sizeof(aHeader->dataOffset) into:&aHeader->dataOffset] ||
		![fork read:sizeof(aHeader->mapOffset) into:&aHeader->mapOffset] ||
		![fork read:sizeof(aHeader->dataLength) into:&aHeader->dataLength] ||
		![fork read:sizeof(aHeader->mapLength) into:&aHeader->mapLength]) {
		return NO;
	}
	
	// swap from big endian to host
	aHeader->dataOffset = CFSwapInt32BigToHost(aHeader->dataOffset);
	aHeader->mapOffset = CFSwapInt32BigToHost(aHeader->mapOffset);
	aHeader->dataLength = CFSwapInt32BigToHost(aHeader->dataLength);
	aHeader->mapLength = CFSwapInt32BigToHost(aHeader->mapLength);
	
	unsigned fileLength = [fork length];
	if ((aHeader->dataOffset + aHeader->dataLength > fileLength) || (aHeader->mapOffset + aHeader->mapLength > fileLength)) {
		return NO;
	}
	
	return YES;
}

- (BOOL)readMap
{
	// seek to the map offset
	if (![fork seekTo:header->mapOffset]) {
		return NO;
	}
	
	// read the map values
	map = calloc(1, sizeof(FVResourceMap));
	if ([self readHeader:&map->headerCopy] == NO) {
		return NO;
	}
	
	// the map contains a copy of the header, or all 0s
	char zeros[16] = {0};
	if (memcmp(&map->headerCopy, header, sizeof(FVResourceHeader)) != 0 && memcmp(&map->headerCopy, zeros, sizeof(zeros)) != 0) {
		printf("Bad match!\n");
	}
	
	if (![fork read:sizeof(map->nextMap) into:&map->nextMap] ||
		![fork read:sizeof(map->fileRef) into:&map->fileRef] ||
		![fork read:sizeof(map->attributes) into:&map->attributes] ||
		![fork read:sizeof(map->typesOffset) into:&map->typesOffset] ||
		![fork read:sizeof(map->namesOffset) into:&map->namesOffset]) {
		return NO;
	}
	
	// swap from big endian to host
	map->nextMap = CFSwapInt32BigToHost(map->nextMap);
	map->fileRef = CFSwapInt16BigToHost(map->fileRef);
	map->attributes = CFSwapInt16BigToHost(map->attributes);
	map->typesOffset = CFSwapInt16BigToHost(map->typesOffset);
	map->namesOffset = CFSwapInt16BigToHost(map->namesOffset);
	
	//NSLog(@"MAP (%u, %u, %x, %u, %u)", map->nextMap, map->fileRef, map->attributes, map->typesOffset, map->namesOffset);
	
	return YES;
}

- (BOOL)readTypes
{
	unsigned typesOffset = [fork position];
	
	uint16_t numberOfTypes;
	if (![fork read:sizeof(numberOfTypes) into:&numberOfTypes]) {
		return NO;
	}
	numberOfTypes = CFSwapInt16BigToHost(numberOfTypes) + 1;
	
	NSMutableArray *typesTemp = [NSMutableArray array];
	
	for (uint16_t typeIndex=0; typeIndex<numberOfTypes; typeIndex++) {
		uint32_t type;
		uint16_t numberOfResources;
		uint16_t referenceListOffset;
		
		if (![fork read:sizeof(type) into:&type] ||
			![fork read:sizeof(numberOfResources) into:&numberOfResources] ||
			![fork read:sizeof(referenceListOffset) into:&referenceListOffset]) {
			return NO;
		}
		
		type = CFSwapInt32BigToHost(type);
		numberOfResources = CFSwapInt16BigToHost(numberOfResources) + 1;
		referenceListOffset = CFSwapInt16BigToHost(referenceListOffset);
		
		FVResourceType *obj = [[FVResourceType alloc] init];
		obj.type = type;
		obj.count = numberOfResources;
		obj.offset = referenceListOffset;
		[typesTemp addObject:obj];
		
		//NSLog(@"[%u]: %@, %u, %u", typeIndex+1, NSFileTypeForHFSTypeCode(type), numberOfResources, referenceListOffset);
	}
	
	for (FVResourceType *obj in typesTemp) {
		NSMutableArray *resourcesTemp = [NSMutableArray array];
		
		for (uint16_t resIndex=0; resIndex<obj.count; resIndex++) {
			if (![fork seekTo:typesOffset + obj.offset + (resIndex * 12)]) {
				return NO;
			}
			
			uint16_t resourceID;
			int16_t nameOffset;
			uint8_t attributes;
			uint8_t dataOffsetBytes[3];
			uint32_t resHandle;
			if (![fork read:sizeof(resourceID) into:&resourceID] ||
				![fork read:sizeof(nameOffset) into:&nameOffset] ||
				![fork read:sizeof(attributes) into:&attributes] ||
				![fork read:sizeof(dataOffsetBytes) into:&dataOffsetBytes] ||
				![fork read:sizeof(resHandle) into:&resHandle]) {
					return NO;
			}
			
			resourceID = CFSwapInt16BigToHost(resourceID);
			nameOffset = CFSwapInt16BigToHost(nameOffset);
			resHandle = CFSwapInt32BigToHost(resHandle);
			
			uint32_t dataOffset = 0;
			dataOffset |= dataOffsetBytes[0] << 16;
			dataOffset |= dataOffsetBytes[1] << 8;
			dataOffset |= dataOffsetBytes[2];
			
			char name[256];
			uint8_t nameLength = 0;
			if ((nameOffset != -1) && ([fork seekTo:header->mapOffset + map->namesOffset + nameOffset])) {
				if (![fork read:sizeof(nameLength) into:&nameLength] || ![fork read:nameLength into:name]) {
					nameLength = 0;
				}
			}
			name[nameLength] = 0;
			
			uint32_t dataLength = 0;
			if ([fork seekTo:header->dataOffset + dataOffset] && [fork read:sizeof(dataLength) into:&dataLength]) {
				dataLength = CFSwapInt32BigToHost(dataLength);
			}
			
			//NSLog(@"%@[%u] %u %s", obj.typeString, resourceID, dataLength, name);
			FVResource *resource = [[FVResource alloc] init];
            resource.ident = resourceID;
            resource.dataSize = dataLength;
            resource.dataOffset = dataOffset + sizeof(dataOffset);
			if (strlen(name)) {
				[resource setName:[NSString stringWithCString:name encoding:NSMacOSRomanStringEncoding]];
			}
			resource.file = self;
			resource.type = obj;
			[resourcesTemp addObject:resource];
		}
		
		NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"ident" ascending:YES];
		[resourcesTemp sortUsingDescriptors:[NSArray arrayWithObject:sort]];
		
		obj.resources = resourcesTemp;
	}		
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"typeString" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	[typesTemp sortUsingDescriptors:[NSArray arrayWithObject:sort]];
	
	types = typesTemp;
	
	return YES;
}

- (NSData *)dataForResource:(FVResource *)resource
{
	if (![fork seekTo:header->dataOffset + resource.dataOffset]) {
		return nil;
	}
	NSMutableData *data = [NSMutableData dataWithLength:resource.dataSize];
	if (!data) {
		return nil;
	}
	if (![fork read:resource.dataSize into:[data mutableBytes]]) {
		return nil;
	}
	return data;
}

- (FVForkType)forkType
{
	return fork.type;
}

@end
