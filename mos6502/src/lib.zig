// vim: set foldmethod=marker
const std = @import("std");

// {{{ ADC
pub fn makeADC_I(value: u8) [2]u8 {
    return .{ 0x69, value };
}

pub fn makeADC_ZP(address: u8) [2]u8 {
    return .{ 0x65, address };
}

pub fn makeADC_ZPX(address: u8) [2]u8 {
    return .{ 0x75, address };
}

pub fn makeADC_A(address: u16) [3]u8 {
    return .{ 0x6D, @truncate(address & 0xFF), @truncate(address >> 8) };
}

pub fn makeADC_AX(address: u16) [3]u8 {
    return .{ 0x7D, @truncate(address & 0xFF), @truncate(address >> 8) };
}

pub fn makeADC_AY(address: u16) [3]u8 {
    return .{ 0x79, @truncate(address & 0xFF), @truncate(address >> 8) };
}

pub fn makeADC_INX(address: u8) [2]u8 {
    return .{ 0x61, address };
}

pub fn makeADC_INY(address: u8) [2]u8 {
    return .{ 0x71, address };
}

// }}}

pub fn makeLDA_I(value: u8) [2]u8 {
    return .{ 0xA9, value };
}

pub fn makeSTA_ZP(address: u8) [2]u8 {
    return .{ 0x85, address };
}

pub fn makeSTA_A(address: u16) [3]u8 {
    return .{ 0x8D, @truncate(address & 0xFF), @truncate(address >> 8) };
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

pub fn makeSEI() [1]u8 {
    return .{0x78};
}

pub fn makeCLD() [1]u8 {
    return .{0xD8};
}
