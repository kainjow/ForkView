//
//  FVSNDTypeController.swift
//  ForkView
//
//  Created by Kevin Wojniak on 5/2/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa
import AudioToolbox
import AVKit
import AVFoundation

final class FVSNDTypeController: FVTypeController {
    func supportedTypes() -> [String] {
        return ["snd "]
    }
    
    func viewControllerFromResource(resource: FVResource, inout errmsg: String) -> NSViewController? {
        if let asset = assetForSND(resource.data!, errmsg: &errmsg) {
            let playerView = AVPlayerView(frame: NSMakeRect(0, 0, 100, 100))
            playerView.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            playerView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
            playerView.player.play()
            let viewController = FVSNDViewController()
            viewController.view = playerView
            return viewController
        }
        return nil
    }

    func assetForSND(data: NSData, inout errmsg: String) -> AVAsset? {
        // See Sound.h in Carbon
        let firstSoundFormat: Int16  = 0x0001 /*general sound format*/
        let secondSoundFormat: Int16 = 0x0002 /*special sampled sound format (HyperCard)*/
        let initMono:   Int32 = 0x0080 /*monophonic channel*/
        let initStereo: Int32 = 0x00C0 /*stereo channel*/
        let initMACE3:  Int32 = 0x0300 /*MACE 3:1*/
        let initMACE6:  Int32 = 0x0400 /*MACE 6:1*/
        let nullCmd: UInt16   = 0
        let soundCmd: UInt16  = 80
        let bufferCmd: UInt16 = 81
        let stdSH: UInt8 = 0x00 /*Standard sound header encode value*/
        let extSH: UInt8 = 0xFF /*Extended sound header encode value*/
        let cmpSH: UInt8 = 0xFE /*Compressed sound header encode value*/
        struct ModRef {
            var modNumber: UInt16 = 0
            var modInit: Int32 = 0
        }
        struct SndCommand {
            var cmd: UInt16 = 0
            var param1: Int16 = 0
            var param2: Int32 = 0
        }
        struct SndListResource {
            var format: Int16 = 0
            var numModifiers: Int16 = 0
            var modifierPart = ModRef()
            var numCommands: Int16 = 0
            var commandPart = SndCommand()
        }
        struct Snd2ListResource {
            var format: Int16 = 0
            var refCount: Int16 = 0
            var numCommands: Int16 = 0
            var commandPart = SndCommand()
        }
        struct SoundHeader {
            var samplePtr: UInt32
            var length: UInt32
            var sampleRate: UInt32
            var loopStart: UInt32
            var loopEnd: UInt32
            var encode: UInt8
            var baseFrequency: UInt8
        }
        
        let reader = FVDataReader(data)
        
        var format = Int16()
        if !reader.readInt16(.Big, &format) {
            errmsg = "Missing header"
            return nil
        }
        var header_offset = Int()
        if format == firstSoundFormat {
            var listResource = SndListResource()
            if !reader.readInt16(.Big, &listResource.numModifiers) ||
                !reader.readUInt16(.Big, &listResource.modifierPart.modNumber) ||
                !reader.readInt32(.Big, &listResource.modifierPart.modInit) ||
                !reader.readInt16(.Big, &listResource.numCommands) {
                errmsg = "Missing header"
                return nil
            }
            if listResource.numModifiers != 1 || listResource.numCommands == 0 {
                errmsg = "Bad header"
                return nil
            }
            if listResource.modifierPart.modNumber != 5  {
                errmsg = "Unknown modNumber value \(listResource.modifierPart.modNumber)"
                return nil
            }
            if listResource.modifierPart.modInit & initStereo == 1 {
                errmsg = "Only mono channel supported"
                return nil
            }
            if listResource.modifierPart.modInit & initMACE3 == 1 || listResource.modifierPart.modInit & initMACE6 == 1 {
                errmsg = "Compression not supported"
                return nil
            }
            for var i = Int16(0); i < listResource.numCommands; ++i {
                if !reader.readUInt16(.Big, &listResource.commandPart.cmd) ||
                    !reader.readInt16(.Big, &listResource.commandPart.param1) ||
                    !reader.readInt32(.Big, &listResource.commandPart.param2) {
                    errmsg = "Missing command"
                    return nil
                }
                listResource.commandPart.cmd &= ~0x8000
                switch listResource.commandPart.cmd {
                case soundCmd, bufferCmd:
                    if header_offset != 0 {
                        errmsg = "Duplicate commands"
                        return nil
                    }
                    header_offset = Int(listResource.commandPart.param2)
                case nullCmd:
                    break
                default:
                    errmsg = "Unknown command \(listResource.commandPart.cmd)"
                    return nil
                }
            }
        } else if format == secondSoundFormat {
            var listResource = Snd2ListResource()
            if !reader.readInt16(.Big, &listResource.refCount) ||
                !reader.readInt16(.Big, &listResource.numCommands) {
                errmsg = "Missing header"
                return nil
            }
            if listResource.numCommands == 0 {
                errmsg = "Bad header"
                return nil
            }
            for var i = Int16(0); i < listResource.numCommands; ++i {
                if !reader.readUInt16(.Big, &listResource.commandPart.cmd) ||
                    !reader.readInt16(.Big, &listResource.commandPart.param1) ||
                    !reader.readInt32(.Big, &listResource.commandPart.param2) {
                    errmsg = "Missing command"
                    return nil
                }
                listResource.commandPart.cmd &= ~0x8000
                switch listResource.commandPart.cmd {
                case soundCmd, bufferCmd:
                    if header_offset != 0 {
                        errmsg = "Duplicate commands"
                        return nil
                    }
                    header_offset = Int(listResource.commandPart.param2)
                case nullCmd:
                    break
                default:
                    errmsg = "Unknown command \(listResource.commandPart.cmd)"
                    return nil
                }
            }
        } else {
            errmsg = "Unknown format \(format)"
            return nil
        }
        
        let header = reader.unpack("IIIIIBB", endian: .Big)
        if header == nil {
            errmsg = "Missing data"
            return nil
        }
        let header_length = Int(header![1] as! UInt32)
        let sampleData = reader.read(header_length)
        if sampleData == nil {
            errmsg = "Missing samples"
            return nil
        }
        
        let sample_rate = Int(header![2] as! UInt32)
        
        let encode = header![5] as! UInt8
        if encode != stdSH {
            if encode == extSH {
                errmsg = "Extended encoding not supported"
            } else if encode == cmpSH {
                errmsg = "Compression not supported"
            } else {
                errmsg = String(format: "Unknown encoding 0x%02X", encode)
            }
            return nil
        }
        
        var stream = AudioStreamBasicDescription()
        stream.mSampleRate = Float64(sample_rate >> 16)
        stream.mFormatID = AudioFormatID(kAudioFormatLinearPCM)
        stream.mFormatFlags = AudioFormatFlags(kLinearPCMFormatFlagIsSignedInteger)
        stream.mBytesPerPacket = 1
        stream.mFramesPerPacket = 1
        stream.mBytesPerFrame = 1
        stream.mChannelsPerFrame = 1
        stream.mBitsPerChannel = 8
        
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingFormat("%d-%f.aif", arc4random(), NSDate().timeIntervalSinceReferenceDate))
        if url == nil {
            errmsg = "Can't make url for conversion"
            return nil
        }
        var audioFile: ExtAudioFileRef = nil
        let createStatus = ExtAudioFileCreateWithURL(url, AudioFileTypeID(kAudioFileAIFFType), &stream, nil, UInt32(kAudioFileFlags_EraseFile), &audioFile)
        if createStatus != noErr {
            errmsg = "ExtAudioFileCreateWithURL failed with status \(createStatus)"
            return nil
        }
        
        let srcData = UnsafePointer<UInt8>(sampleData!.bytes)
        var audioBuffer = AudioBuffer()
        audioBuffer.mNumberChannels = 1
        audioBuffer.mDataByteSize = UInt32(header_length)
        audioBuffer.mData = UnsafeMutablePointer(srcData)
        var audioBufferData = UnsafeMutablePointer<UInt8>(audioBuffer.mData)
        for var i = 0; i < header_length; ++i {
            audioBufferData[i] ^= 0x80
        }
        
        var bufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: audioBuffer)
        let writeStatus = ExtAudioFileWrite(audioFile, UInt32(header_length), &bufferList)
        if writeStatus != noErr {
            errmsg = "ExtAudioFileWrite failed with status \(writeStatus)"
            return nil
        }
        
        let disposeStatus = ExtAudioFileDispose(audioFile)
        if disposeStatus != noErr {
            errmsg = "ExtAudioFileDispose failed with status \(disposeStatus)"
            return nil
        }
        
        return AVAsset.assetWithURL(url) as? AVAsset
    }
}

final class FVSNDViewController: NSViewController {
    override func viewWillDisappear() {
        if let playerView = self.view as? AVPlayerView {
            playerView.player.pause()
        }
    }
}
