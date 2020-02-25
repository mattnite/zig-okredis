//  GEOADD key longitude latitude member [longitude latitude member ...]

const std = @import("std");

pub const GEOADD = struct {
    key: []const u8,
    points: []const GeoPoint,

    pub const GeoPoint = struct {
        long: f64,
        lat: f64,
        member: []const u8,

        pub const RedisArguments = struct {
            pub fn count(self: GeoPoint) usize {
                return 3;
            }

            pub fn serialize(self: GeoPoint, comptime rootSerializer: type, msg: var) !void {
                try rootSerializer.serializeArgument(msg, f64, self.long);
                try rootSerializer.serializeArgument(msg, f64, self.lat);
                try rootSerializer.serializeArgument(msg, []const u8, self.member);
            }
        };
    };

    /// Instantiates a new GEOADD command.
    pub fn init(key: []const u8, points: []const GeoPoint) HSET {
        return .{ .key = key, .points = points };
    }

    /// Validates if the command is syntactically correct.
    pub fn validate(self: GEOADD) !void {
        if (self.points.len == 0) return error.PointsArrayIsEmpty;
    }

    pub const RedisCommand = struct {
        pub fn serialize(self: HSET, comptime rootSerializer: type, msg: var) !void {
            return rootSerializer.serializeCommand(msg, .{ "GEOADD", self.key, self.points });
        }
    };
};

test "basic usage" {
    const cmd = GEOADD.init("mykey", &[_]GEOADD.GeoPoint{
        .{ 80.05, 80.05, "place1" },
        .{ 81.05, 81.05, "place2" },
    });

    try cmd.validate();
}