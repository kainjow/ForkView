//
//  FVSNDTypeController.swift
//  ForkView
//
//  Created by Kevin Wojniak on 5/2/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

import Cocoa
import AudioToolbox

final class FVSNDTypeController: FVTypeController {
    func supportedTypes() -> [String] {
        return ["snd "]
    }
    
    var player: FVSNDPlayer? = nil
    
    func viewControllerFromResource(resource: FVResource) -> NSViewController? {
        player = FVSNDPlayer(resource.data!)
        if player != nil {
            player!.play()
        }
        return nil
    }
}

final class FVSNDPlayer {
    private var queue: AudioQueueRef = nil
    private var buffer: AudioQueueBufferRef = nil
    
    init?(_ data: NSData) {
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
        
        //let duration = Float(header_length) / Float(sample_rate >> 16)
        //println("duration: \(duration)")
        
        var stream = AudioStreamBasicDescription()
        stream.mSampleRate = Float64(sample_rate >> 16)
        stream.mFormatID = AudioFormatID(kAudioFormatLinearPCM)
        stream.mFormatFlags = 0
        stream.mBytesPerPacket = 1
        stream.mFramesPerPacket = 1
        stream.mBytesPerFrame = 1
        stream.mChannelsPerFrame = 1
        stream.mBitsPerChannel = 8
        
        var status = FVAudioQueueNewOutput(&stream, &queue)
        if status != noErr {
            println("AudioQueueNewOutput: \(status)")
            return nil
        }
        
        status = AudioQueueAllocateBuffer(queue, UInt32(header_length), &buffer)
        if status != noErr {
            println("AudioQueueAllocateBuffer: \(status)")
            AudioQueueDispose(queue, Boolean(1))
            return nil
        }
        
        var buf = UnsafeMutablePointer<AudioQueueBuffer>(buffer)
        buf[0].mAudioDataByteSize = UInt32(header_length)
        var audioData = UnsafeMutablePointer<UInt8>(buf[0].mAudioData)
        let srcData = UnsafePointer<UInt8>(data.bytes)
        memcpy(audioData, srcData, header_length)
    }
    
    func play() -> Bool {
        if queue == nil || buffer == nil {
            return false
        }
        
        let status1 = AudioQueueEnqueueBuffer(queue, buffer, 0, nil)
        if status1 != noErr {
            println("AudioQueueEnqueueBuffer: \(status1)")
            return false
        }
        
        let status2 = AudioQueueStart(queue, nil)
        if status2 != noErr {
            println("AudioQueueStart: \(status2)")
            return false
        }
        
        return true
    }
}
