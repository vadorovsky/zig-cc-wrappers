# Zig CC wrappers

This repository provides two tiny Zig executables, `zig-cc` and `zig-c++`, that
simply forward every argument to `zig cc` or `zig c++`. They exist so tools such
as CMake can pretend they are interacting with standalone `cc`/`c++` binaries
while you still get Zig's cross-compiling toolchains.

## Usage

1. Build and install the wrappers (by default they land in `zig-out/bin/`):
   ```sh
   zig build install
   ```
2. Make sure that directory is on your `PATH` _before_ the system compilers, e.g.:
   ```sh
   export PATH="/path/to/zig-cc-wrappers/zig-out/bin:$PATH"
   ```
3. Point your build system at the wrappers. For CMake, from a clean build tree:
   ```sh
   cmake -S . -B build \
     -DCMAKE_C_COMPILER=zig-cc \
     -DCMAKE_CXX_COMPILER=zig-c++
   ```
4. Configure or build as usual. Every argument CMake forwards will be proxied to
   the real `zig cc`/`zig c++`.

If you need to use a specific Zig binary, just adjust your `PATH` so that `zig`
resolves to the desired executable before invoking the wrappers.

## Releases

GitLab and GitHub automatically publish release tarballs containing both
wrappers built for:

- `zig-cc-wrappers-aarch64-linux-musl.tar.gz`
- `zig-cc-wrappers-riscv64-linux-musl.tar.gz`
- `zig-cc-wrappers-x86_64-linux-musl.tar.gz`

Download the archive matching your target, extract, and place the files on your
`PATH` if you prefer not to build them yourself.

## GitLab CI

A matching pipeline lives in `.gitlab-ci.yml` for GitLab mirrors. It runs the
same three-target matrix using the Gentoo musl container, publishes artifacts
for every pipeline, and creates GitLab releases on tags using `glab`
(`gitlab/glab`). No extra token is needed: the release job authenticates with
`glab auth login --job-token "$CI_JOB_TOKEN"` and uploads the generated
tarballs as release assets automatically.
