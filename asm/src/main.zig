const std = @import("std");

const mos6502 = @import("mos6502");

pub fn main() !void {
    std.debug.print("TEst", .{});
    var kernelFile = try std.fs.cwd().createFile("test.nes", .{});

    var writer = binWriter(kernelFile.writer());

    writer.write(&[_]u8{ 'N', 'E', 'S', 0x1A });
    writer.write(&[_]u8{ 1, 1 });
    writer.write(&[_]u8{ 0b00000000, 0b00001000, 0, 0, 0, 0, 0, 0, 0, 0 });

    var prg = bufferWriter(0x4000);

    prg.write(&mos6502.makeSEI());
    prg.write(&mos6502.makeCLD());

    prg.write(&mos6502.makeLDA_I(0b00001000));
    prg.write(&mos6502.makeSTA_A(0x2000));
    prg.write(&mos6502.makeLDA_I(0b00011110));
    prg.write(&mos6502.makeSTA_A(0x2001));

    prg.write(&mos6502.makeLDA_I(0x00));
    prg.write(&mos6502.makeSTA_A(0x2005));
    prg.write(&mos6502.makeSTA_A(0x2005));

    // Forever
    const address = prg.mark();
    prg.write(&mos6502.makeJMP_A(0x8000 + address));

    prg.seek(0x4000 - 6);
    prg.write(&[_]u8{ 0x00, 0x00, 0x00, 0x80, 0x00, 0x00 });

    writer.write(prg.flush());

    for (0..(8192 * 1)) |_| {
        writer.write(&[_]u8{0});
    }

    // const staVBLANK = &lib6502.makeSTA_ZP(0x01);
    // const staVSYNC = &lib6502.makeSTA_ZP(0x00);
    // const staWSYNC = &lib6502.makeSTA_ZP(0x02);
    //
    // const COLUBK = 0x09;
    //
    // writer.write(&lib6502.makeLDA_I(0));
    // writer.write(staVBLANK);
    // writer.write(&lib6502.makeLDA_I(2));
    // writer.write(staVSYNC);
    //
    // for (0..3) |_| {
    //     writer.write(staWSYNC);
    // }
    //
    // writer.write(&lib6502.makeLDA_I(0));
    // writer.write(staVSYNC);
    //
    // for (0..37) |_| {
    //     writer.write(staWSYNC);
    // }
    //
    // writer.write(&lib6502.makeLDX_I(0));
    // for (0..192) |_| {
    //     writer.write(&lib6502.makeINX());
    //     writer.write(&lib6502.makeSTX_ZP(COLUBK));
    //     writer.write(staWSYNC);
    // }
    //
    // writer.write(&lib6502.makeLDA_I(0b01000010));
    // writer.write(staVBLANK);
    //
    // // 30 lines of overscan
    // for (0..30) |_| {
    //     writer.write(staWSYNC);
    // }
    //
    // writer.write(&lib6502.makeJMP_A(0xF000));
    //
    // writer.finish();
    //
    // const symbolTable = [_]u8{ 0x00, 0xF0, 0x00, 0xF0, 0x00, 0xF0 };
    //
    // writer.write(&symbolTable);

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

const BufferWriter = struct {
    const Self = @This();
    cursor: u16,
    buffer: []u8,

    pub fn init(length: u16) Self {
        return Self{
            .cursor = 0,
            .buffer = std.heap.page_allocator.alloc(u8, length) catch unreachable,
        };
    }

    pub fn write(self: *Self, data: []const u8) void {
        for (0..data.len) |i| {
            self.buffer[self.cursor + i] = data[i];
        }
        self.cursor += @intCast(data.len);
    }

    pub fn seek(self: *Self, index: u16) void {
        self.cursor = index;
    }

    pub fn flush(self: *Self) []u8 {
        return self.buffer;
    }

    pub fn mark(self: *Self) u16 {
        return self.cursor;
    }
};

pub fn bufferWriter(comptime length: u16) BufferWriter {
    return BufferWriter.init(length);
}
