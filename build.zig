const std = @import("std");
const zine = @import("zine");

pub fn build(b: *std.Build) !void {
    const build_css = b.addSystemCommand(&.{ "bun", "build", "--minify", "-e", "*.woff2", "-e", "*.ttf" });
    build_css.addFileArg(b.path("assets/css/main.css"));
    try addSourceFilesAsInputs(b, build_css, "assets/css", &.{ ".css" });
    const css_output = build_css.addPrefixedOutputFileArg("--outfile=", "main.css");
    build_css.expectExitCode(0);

    const build_js = b.addSystemCommand(&.{ "bun", "build", "--minify" });
    build_js.addFileArg(b.path("assets/scripts/index.ts"));
    try addSourceFilesAsInputs(b, build_js, "assets/scripts", &.{ ".js", ".ts" });
    const js_output = build_js.addPrefixedOutputFileArg("--outfile=", "index.js");
    build_js.expectExitCode(0);

    const zine_opts: zine.Options = .{
        .build_assets = &.{
            .{
                .name = "main.css",
                .lp = css_output,
                .install_path = "style.css",
            },
            .{
                .name = "index.js",
                .lp = js_output,
                .install_path = "index.js",
            },
        },
    };
    b.getInstallStep().dependOn(&zine.website(b, zine_opts).step);

    const serve = b.step("serve", "Start the Zine dev server");
    const run_zine = zine.serve(b, zine_opts);
    serve.dependOn(&run_zine.step);
}

fn addSourceFilesAsInputs(
    b: *std.Build,
    run: *std.Build.Step.Run,
    dir_path: []const u8,
    extensions: []const []const u8,
) !void {
    var dir = try b.build_root.handle.openDir(dir_path, .{ .iterate = true });
    defer dir.close();

    var walker = try dir.walk(b.allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        if (entry.kind != .file) continue;
        if (!hasExtension(entry.basename, extensions)) continue;

        const rel_path = try std.fs.path.join(b.allocator, &.{ dir_path, entry.path });
        defer b.allocator.free(rel_path);

        run.addFileInput(b.path(rel_path));
    }
}

fn hasExtension(path: []const u8, extensions: []const []const u8) bool {
    for (extensions) |ext| {
        if (std.mem.endsWith(u8, path, ext)) return true;
    }
    return false;
}
