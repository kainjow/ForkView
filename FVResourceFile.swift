//
//  FVResourceFile.swift
//  ForkView
//
//  Created by C.W. Betts on 5/12/15.
//

import Foundation

extension NSError {
    fileprivate class func errorWithDescription(_ description: String) -> NSError {
        return NSError(domain: "FVResourceErrorDomain", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey: description])
    }
}

private func ==(lhs: FVResourceFile.ResourceHeader, rhs: FVResourceFile.ResourceHeader) -> Bool {
    if lhs.dataOffset != rhs.dataOffset {
        return false
    } else if lhs.mapOffset != rhs.mapOffset {
        return false
    } else if lhs.dataLength != rhs.dataLength {
        return false
    } else if lhs.mapLength != rhs.mapLength {
        return false
    }

    return true
}

final public class FVResourceFile: NSObject {
    @objc var types: [FVResourceType] = []
    @objc var isResourceFork = false

    private var header = ResourceHeader()
    private var map = ResourceMap()
    private let dataReader: FVDataReader!

    fileprivate struct ResourceHeader: Equatable {
        var dataOffset: UInt32 = 0
        var mapOffset: UInt32 = 0
        var dataLength: UInt32 = 0
        var mapLength: UInt32 = 0
    }

    private struct ResourceMap {
        var headerCopy = ResourceHeader()
        var nextMap: UInt32 = 0
        var fileRef: UInt16 = 0
        var attributes: UInt16 = 0
        var typesOffset: UInt16 = 0
        var namesOffset: UInt16 = 0
    }

    private func readHeader(_ aHeader: inout ResourceHeader) -> Bool {
        // read the header values
        if !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: aHeader.dataOffset)), into: &aHeader.dataOffset) ||
            !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: aHeader.mapOffset)), into: &aHeader.mapOffset) ||
            !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: aHeader.dataLength)), into: &aHeader.dataLength) ||
            !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: aHeader.mapLength)), into: &aHeader.mapLength) {
                return false
        }

        // swap from big endian to host
        aHeader.dataOffset = aHeader.dataOffset.bigEndian
        aHeader.mapOffset = aHeader.mapOffset.bigEndian
        aHeader.dataLength = aHeader.dataLength.bigEndian
        aHeader.mapLength = aHeader.mapLength.bigEndian

        let fileLength = UInt32(dataReader.length)
        if (aHeader.dataOffset + aHeader.dataLength > fileLength) || (aHeader.mapOffset + aHeader.mapLength > fileLength) {
            return false
        }

        return true
    }

    private init(contentsOfURL fileURL: NSURL, resourceFork: Bool) throws {
        if let dataReader = FVDataReader(url: fileURL, resourceFork: resourceFork) {
            self.dataReader = dataReader
            super.init()

            if !readHeader(&header) {
                throw NSError.errorWithDescription("Invalid header.")
            }

            //NSLog(@"HEADER (%u, %u), (%u, %u)", header->dataOffset, header->dataLength, header->mapOffset, header->mapLength);

            if !readMap() {
                throw NSError.errorWithDescription("Invalid map.")
            }

            if !readTypes() {
                throw NSError.errorWithDescription("Invalid types list.")
            }

            // Don't open empty (but valid) resource forks
            if types.count == 0 {
                throw NSError.errorWithDescription("No resources.")
            }
            return
        } else {
            self.dataReader = nil
            super.init()

            throw NSError.errorWithDescription("Bad File.")
        }
    }

    private func readMap() -> Bool {
        // seek to the map offset
        if !dataReader.seekTo(Int(header.mapOffset)) {
            return false
        }

        // read the map values
        if !readHeader(&map.headerCopy) {
            return false
        }

        let zeros = [Int8](repeating: 0, count: 16)
        if (map.headerCopy != header) && (memcmp(&map.headerCopy, zeros, zeros.count) != 0) {
            print("Bad match!")
        }

        if !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: map.nextMap)), into: &map.nextMap) ||
            !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: map.fileRef)), into: &map.fileRef) ||
            !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: map.attributes)), into: &map.attributes) ||
            !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: map.typesOffset)), into: &map.typesOffset) ||
            !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: map.namesOffset)), into: &map.namesOffset) {
                return false
        }

        map.nextMap = map.nextMap.bigEndian
        map.fileRef = map.fileRef.bigEndian
        map.attributes = map.attributes.bigEndian
        map.typesOffset = map.typesOffset.bigEndian
        map.namesOffset = map.namesOffset.bigEndian

        return true
    }

    private func readTypes() -> Bool {
        let typesOffset = dataReader.position

        var numberOfTypes: UInt16 = 0
        if !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: numberOfTypes)), into: &numberOfTypes) {
            return false
        }
        numberOfTypes = numberOfTypes.bigEndian + 1

        var typesTemp = [FVResourceType]()
        for _ in 0..<numberOfTypes {
            var type: OSType = 0
            var numberOfResources: UInt16 = 0
            var referenceListOffset: UInt16 = 0
            if !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: type)), into: &type) ||
                !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: numberOfResources)), into: &numberOfResources) ||
                !dataReader.read(CUnsignedInt(MemoryLayout.size(ofValue: referenceListOffset)), into: &referenceListOffset) {
                    return false
            }
            type = type.bigEndian
            numberOfResources = numberOfResources.bigEndian + 1
            referenceListOffset = referenceListOffset.bigEndian

            let obj = FVResourceType()
            obj.type = type
            obj.count = UInt32(numberOfResources)
            obj.offset = UInt32(referenceListOffset)
            typesTemp.append(obj)
        }

        for obj in typesTemp {
            var tmpResources = [FVResource]()

            for resIndex in 0..<obj.count {
                if !dataReader.seekTo(typesOffset + Int(obj.offset) + Int(resIndex * 12)) {
                    return false
                }

                var resourceID: UInt16 = 0
                var nameOffset: Int16 = 0
                var attributes: UInt8 = 0
                var dataOffsetBytes: (UInt8, UInt8, UInt8) = (0, 0, 0)
                var resHandle: UInt32 = 0

                if !dataReader.read(UInt32(MemoryLayout.size(ofValue: resourceID)), into: &resourceID) ||
                    !dataReader.read(UInt32(MemoryLayout.size(ofValue: nameOffset)), into: &nameOffset) ||
                    !dataReader.read(UInt32(MemoryLayout.size(ofValue: attributes)), into: &attributes) ||
                    !dataReader.read(UInt32(MemoryLayout.size(ofValue: dataOffsetBytes)), into: &dataOffsetBytes) ||
                    !dataReader.read(UInt32(MemoryLayout.size(ofValue: resHandle)), into: &resHandle) {
                        return false
                }

                resourceID = resourceID.bigEndian
                nameOffset = nameOffset.bigEndian
                resHandle = resHandle.bigEndian

                let dataOffset: UInt32 = {
                    var toRet = UInt32(dataOffsetBytes.2)
                    toRet |= UInt32(dataOffsetBytes.0) << 16
                    toRet |= UInt32(dataOffsetBytes.1) << 8

                    return toRet
                }()

                var name = [Int8](repeating: 0, count: 256)
                var nameLength: UInt8 = 0

                if (nameOffset != -1) && (dataReader.seekTo(Int(header.mapOffset) + Int(map.namesOffset) + Int(nameOffset))) {
                    if !dataReader.read(UInt32(MemoryLayout.size(ofValue: nameLength)), into: &nameLength) || !dataReader.read(UInt32(nameLength), into: &name) {
                        nameLength = 0
                    }
                }
                name[Int(nameLength)] = 0

                var dataLength: UInt32 = 0
                if dataReader.seekTo(Int(header.dataOffset + dataOffset)) && dataReader.read(UInt32(MemoryLayout.size(ofValue: dataLength)), into: &dataLength) {
                    dataLength = dataLength.bigEndian
                }

                //NSLog(@"%@[%u] %u %s", obj.typeString, resourceID, dataLength, name);
                let resource = FVResource()
                resource.ident = resourceID
                resource.dataSize = dataLength
                resource.dataOffset = dataOffset + UInt32(MemoryLayout.size(ofValue: dataOffset))
                if strlen(name) != 0 {
                    resource.name = String(cString: name, encoding: String.Encoding.macOSRoman)!
                }
                resource.file = self
                resource.type = obj
                tmpResources.append(resource)
            }
            tmpResources.sort { (lhs, rhs) -> Bool in
                return lhs.ident > rhs.ident
            }
            obj.resources = tmpResources as NSArray
        }

        typesTemp.sort { (lhs, rhs) -> Bool in
            let compVal = lhs.typeString.caseInsensitiveCompare(rhs.typeString)
            return compVal == .orderedAscending
        }

        types = typesTemp
        return true
    }

    internal func dataForResource(resource: FVResource) -> NSData? {
        if !dataReader.seekTo(Int(header.dataOffset + resource.dataOffset)) {
            return nil
        }
        if let data = NSMutableData(length: Int(resource.dataSize)) {
            if !dataReader.read(resource.dataSize, into: data.mutableBytes) {
                return nil
            }
            return data
        }
        return nil
    }

    // TODO: implement, but how?
    //convenience init?(contentsOfURL fileURL: NSURL, error: NSErrorPointer) {
    //
    //}

    public class func resourceFileWithContentsOfURL(fileURL: URL) throws -> FVResourceFile {
        let url = fileURL as NSURL
        do {
            let file = try FVResourceFile(contentsOfURL: url, resourceFork: true)
            file.isResourceFork = true
            return file
        } catch let error1 {
            var tmpError: Error? = error1
            do {
                let file = try FVResourceFile(contentsOfURL: url, resourceFork: false)
                return file
            } catch let error {
                tmpError = error
            }
            throw tmpError!
        }
    }
}
