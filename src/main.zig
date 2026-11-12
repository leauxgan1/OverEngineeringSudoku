const std = @import("std");
const Io = std.Io;
const Random = std.Random;

const sudoku = @import("sudoku");

pub fn main(init: std.process.Init) !void {

    // Setup Writer
    const io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const out = &stdout_file_writer.interface;

    // Setup source of randomness
    var prng: Random.DefaultPrng = .init(1);
    const rand = prng.random();

    // Setup grid
    var grid: sudoku.Grid = .init();

    // Run generator
    try grid.generateSudoku(rand, 10);

    // Print result
    try out.print("{f}\n", .{grid});

    try out.flush();
}
