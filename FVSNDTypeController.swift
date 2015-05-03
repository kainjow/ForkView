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
    
    func viewControllerFromResource(resource: FVResource) -> NSViewController? {
        if let asset = assetForSND(resource.data!) {
            let playerView = AVPlayerView(frame: NSMakeRect(0, 0, 100, 100))
            playerView.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
            playerView.autoresizingMask = .ViewWidthSizable | .ViewHeightSizable
            playerView.player.play()
            let viewController = NSViewController()
            viewController.view = playerView
            return viewController
        }
        return nil
    }

    func assetForSND(data: NSData) -> AVAsset? {
        struct snd_mod_ref_t {
            var mod_number: UInt16
            var mod_init: UInt32
        }
        let snd_mod_ref_t_size = 6
        struct snd_command_t {
            var cmd: UInt16
            var param1: Int16
            var param2: Int32
        }
        let snd_command_t_size = 8
        struct snd_list_resource_t {
            var format: Int16
            var num_modifies: Int16
            var modifier_part: snd_mod_ref_t
            var num_commands: Int16
            var command_part: snd_command_t
        }
        let snd_list_resource_t_size = 20
        struct snd_header_t {
            var sample_ptr: UInt32
            var length: UInt32
            var sample_rate: UInt32
            var loop_start: UInt32
            var loop_end: UInt32
            var encode: UInt8
            var base_frequency: UInt8
        }
        let snd_header_t_size = 22
        
        let reader = FVDataReader(data)
        let listResource = reader.unpack("hhHIh", endian: .Big)
        if listResource == nil {
            return nil
        }
        
        let format = listResource![0] as! Int16
        if format != 1 {
            // Format is 1 for general format, 2 for newer HyperCard sounds
            return nil
        }
        
        let num_modifiers = Int(listResource![1] as! Int16)
        let num_commands = Int(listResource![4] as! Int16)
        if num_modifiers < 1 || num_commands < 1 {
            return nil
        }
        
        let header_offset = snd_list_resource_t_size + ((num_modifiers - 1) * snd_mod_ref_t_size) + ((num_commands - 1) * snd_command_t_size)
        if !reader.seekTo(header_offset) {
            return nil
        }
        let header = reader.unpack("IIIIIBB", endian: .Big)
        if header == nil {
            return nil
        }
        let header_length = Int(header![1] as! UInt32)
        if header_length != (data.length - (header_offset + snd_header_t_size)) {
            return nil
        }
        
        let sample_rate = Int(header![2] as! UInt32)
        
        let encode = Int(header![5] as! UInt8)
        if encode != 0 {
            // 0x00 for standard, 0xFF for extended, 0xFE for compressed
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
        var audioFile: ExtAudioFileRef = nil
        let createStatus = ExtAudioFileCreateWithURL(url, AudioFileTypeID(kAudioFileAIFFType), &stream, nil, UInt32(kAudioFileFlags_EraseFile), &audioFile)
        if createStatus != noErr {
            println("ExtAudioFileCreateWithURL: \(createStatus)")
            return nil
        }
        
        let srcData = UnsafePointer<UInt8>(data.bytes + header_offset + snd_header_t_size)
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
            println("ExtAudioFileWrite: \(writeStatus)")
            return nil
        }
        
        let disposeStatus = ExtAudioFileDispose(audioFile)
        if disposeStatus != noErr {
            println("ExtAudioFileDispose: \(disposeStatus)")
            return nil
        }
        
        return AVAsset.assetWithURL(url) as? AVAsset
    }
}
