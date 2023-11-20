const std = @import("std");

pub fn makeLDA_I(value: u8) [2]u8 {
    return .{ 0xA9, value };
}

pub fn makeSTA_ZP(address: u8) [2]u8 {
    return .{ 0x85, address };
}

pub fn makeSTX_ZP(address: u8) [2]u8 {
    return .{ 0x86, address };
}

pub fn makeLDX_I(value: u8) [2]u8 {
    return .{ 0xA2, value };
}

pub fn makeINX() [1]u8 {
    return .{0xE8};
}

pub fn makeJMP_A(address: u16) [3]u8 {
    return .{ 0x4C, @truncate(address & 0xFF), @truncate(address >> 8) };
}
