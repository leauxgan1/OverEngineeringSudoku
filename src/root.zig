//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;
const Random = std.Random;

const DEBUG = false;
const GRID_SIZE = 9;
const SUBGRID_SIZE = 3;
const GRID_AREA = GRID_SIZE * GRID_SIZE;

pub const Grid = struct {
    cells: [GRID_AREA]u8,
    row_mask: [GRID_SIZE]MASK_INT = @splat(0),
    col_mask: [GRID_SIZE]MASK_INT = @splat(0),
    subgrid_mask: [GRID_SIZE]MASK_INT = @splat(0),

    pub const MASK_INT = @Int(.unsigned, GRID_SIZE);

    pub fn init() Grid {
        return .{
            .cells = @splat(0),
        };
    }
    pub fn generateSudoku(self: *Grid, rand: Random, num_missing: u8) !void {
        self.setDiagonals(rand);
        try self.fillRemaining();
        self.removeDigits(rand, num_missing);
    }
    pub fn setDiagonals(self: *Grid, rand: Random) void {
        for (0..SUBGRID_SIZE) |d| {
            var num_vals: usize = GRID_SIZE;
            var vals: [GRID_SIZE]u8 = undefined;
            inline for (0..GRID_SIZE) |i| {
                vals[i] = i + 1;
            }
            rand.shuffle(u8, &vals);
            for (0..SUBGRID_SIZE) |r| {
                for (0..SUBGRID_SIZE) |c| {
                    const sum_r = d * SUBGRID_SIZE + r;
                    const sum_c = d * SUBGRID_SIZE + c;
                    const idx = sum_r * GRID_SIZE + sum_c;

                    num_vals -= 1;
                    const v: u8 = vals[num_vals];
                    self.setCell(idx, v);
                }
            }
        }
    }
    fn print_masks(self: *Grid, out: *Io.Writer) !void {
        try out.print("row mask: \n", .{});
        for (0.., self.row_mask) |i, r| {
            try out.print("{d}:\t{b:9}\n", .{ i, r });
        }
        try out.print("col mask: \n", .{});
        for (0.., self.col_mask) |i, c| {
            try out.print("{d}:\t{b:9}\n", .{ i, c });
        }
        try out.print("subgrid mask: \n", .{});
        for (0.., self.subgrid_mask) |i, s| {
            try out.print("{d}:\t{b:9}\n", .{ i, s });
        }
    }
    pub fn fillRemaining(self: *Grid) !void {
        // Initialize stack of indices into grid for backtracking
        var stack_size: usize = 0;
        var stack: [GRID_AREA - SUBGRID_SIZE * GRID_SIZE]usize = undefined;

        var idx: usize = 3;
        var last: u8 = 0;

        outer: while (idx < GRID_AREA) {
            const r = idx / GRID_SIZE;
            const c = idx % GRID_SIZE;
            const found_val = self.cells[idx];
            if (found_val != 0) {
                idx += 1;
                continue;
            }

            // Try values up to 9
            for (last + 1..9 + 1) |val| {
                if (self.isValidCell(@intCast(val), r, c)) {
                    stack[stack_size] = idx;
                    stack_size += 1;
                    self.setCell(idx, @intCast(val));
                    idx += 1;
                    last = 0;
                    continue :outer;
                }
            }
            // Valid cell not found, time to backtrack
            if (stack_size > 0) {
                stack_size -= 1;
                const last_idx = stack[stack_size];
                idx = last_idx;
                last = self.cells[idx];

                self.unsetCell(idx);
            } else {
                std.debug.print("Exited prematuredly", .{});
                return;
            }
        }
    }
    fn setCell(self: *Grid, idx: usize, val: u8) void {
        // Update cell to new value
        self.cells[idx] = val;

        const r = idx / GRID_SIZE;
        const c = idx % GRID_SIZE;

        // Update bit-masks
        const bit: MASK_INT = @as(u9, 1) << @as(u4, @intCast(val - 1));
        const b = (r / 3) * 3 + (c / 3);

        self.row_mask[r] |= bit;
        self.col_mask[c] |= bit;
        self.subgrid_mask[b] |= bit;
    }
    fn unsetCell(self: *Grid, idx: usize) void {
        const last = self.cells[idx];
        // Update cell to new value
        self.cells[idx] = 0;

        const r = idx / GRID_SIZE;
        const c = idx % GRID_SIZE;

        // Update bit-masks
        const bit: MASK_INT = @as(u9, 1) << @as(u4, @intCast(last - 1));
        const b = (r / 3) * 3 + (c / 3);

        self.row_mask[r] &= ~bit;
        self.col_mask[c] &= ~bit;
        self.subgrid_mask[b] &= ~bit;
    }
    fn isValidCell(self: *Grid, val: u8, r: usize, c: usize) bool {
        const bit: MASK_INT = @as(u9, 1) << @as(u4, @intCast(val - 1));
        const b = (r / 3) * 3 + (c / 3);
        const valid_row = (self.row_mask[r] & bit) < 1;
        const valid_col = (self.col_mask[c] & bit) < 1;
        const valid_subgrid = (self.subgrid_mask[b] & bit) < 1;
        return valid_row and valid_col and valid_subgrid;
    }

    pub fn removeDigits(self: *Grid, rand: Random, num: u8) void {
        var set: [GRID_AREA]u8 = undefined;
        inline for (0..GRID_AREA) |i| {
            set[i] = i;
        }
        rand.shuffle(u8, &set);
        for (0..num) |n| {
            self.cells[set[n]] = 0;
        }
    }
    pub fn format(self: *const Grid, writer: *std.Io.Writer) !void {
        for (0..GRID_SIZE) |r| {
            for (0..GRID_SIZE) |c| {
                try writer.print("[{d}]", .{self.cells[r * GRID_SIZE + c]});
            }
            _ = try writer.write("\n");
        }
    }
};
