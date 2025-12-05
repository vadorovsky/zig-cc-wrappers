const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cc = addWrapper(b, "zig-cc", target, optimize, false);
    b.installArtifact(cc);

    const cxx = addWrapper(b, "zig-c++", target, optimize, true);
    b.installArtifact(cxx);
}

fn addWrapper(
    b: *std.Build,
    name: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    use_cpp: bool,
) *std.Build.Step.Compile {
    const module = b.createModule(.{
        .root_source_file = b.path("src/wrapper.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = name,
        .root_module = module,
    });

    const options = b.addOptions();
    options.addOption(bool, "use_cpp", use_cpp);
    module.addOptions("wrapper_options", options);
    return exe;
}
