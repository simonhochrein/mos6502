const std = @import("std");

const lib6502 = @import("lib6502");

pub fn main() !void {
    var kernelFile = try std.fs.cwd().createFile("kernel_01_zig.bin", .{});

    var writer = binWriter(kernelFile.writer());

    const staVBLANK = &lib6502.makeSTA_ZP(0x01);
    const staVSYNC = &lib6502.makeSTA_ZP(0x00);
    const staWSYNC = &lib6502.makeSTA_ZP(0x02);

    const COLUBK = 0x09;

    writer.write(&lib6502.makeLDA_I(0));
    writer.write(staVBLANK);
    writer.write(&lib6502.makeLDA_I(2));
    writer.write(staVSYNC);

    for (0..3) |_| {
        writer.write(staWSYNC);
    }

    writer.write(&lib6502.makeLDA_I(0));
    writer.write(staVSYNC);

    for (0..37) |_| {
        writer.write(staWSYNC);
    }

    writer.write(&lib6502.makeLDX_I(0));
    for (0..192) |_| {
        writer.write(&lib6502.makeINX());
        writer.write(&lib6502.makeSTX_ZP(COLUBK));
        writer.write(staWSYNC);
    }

    writer.write(&lib6502.makeLDA_I(0b01000010));
    writer.write(staVBLANK);

    // 30 lines of overscan
    for (0..30) |_| {
        writer.write(staWSYNC);
    }

    writer.write(&lib6502.makeJMP_A(0xF000));

    writer.finish();

    const symbolTable = [_]u8{ 0x00, 0xF0, 0x00, 0xF0, 0x00, 0xF0 };

    writer.write(&symbolTable);

    kernelFile.close();
}

fn BinWriter(comptime WriterType: type) type {
    return struct {
        bytes_written: usize = 0,
        writer: std.io.BitWriter(.little, WriterType),

        const Self = @This();

        pub fn init(writer: WriterType) Self {
            return Self{
                .writer = std.io.bitWriter(.little, writer),
            };
        }

        pub fn write(self: *Self, data: []const u8) void {
            self.bytes_written += self.writer.write(data) catch unreachable;
        }

        pub fn finish(self: *Self) void {
            for (self.bytes_written..4090) |_| {
                self.bytes_written += self.writer.write(&.{0xFF}) catch unreachable;
            }
        }
    };
}

pub fn binWriter(stream: anytype) BinWriter(@TypeOf(stream)) {
    return BinWriter(@TypeOf(stream)).init(stream);
}
