# Building V8 `d8` from a Specific Commit

This repository provides a helper script, `build_v8_d8.sh`, for automatically fetching Google V8, checking out a specific commit, configuring the build, and compiling the `d8` shell.

The script supports two build modes:

* Release build, default
* Coverage build, using `--coverage-on`

---

## Requirements

### 1. Install basic system dependencies

On Ubuntu/Debian:

```bash
sudo apt update
sudo apt install git python2 python3 pkg-config g++ libglib2.0-dev
```

Some systems may also need:

```bash
sudo apt install ninja-build
```

---

## Installing `depot_tools`

Clone the `depot_tools` repository:

```bash
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
```

Add `depot_tools` to the front of your `PATH`.

For Bash, add this to `~/.bashrc`:

```bash
export PATH=/path/to/depot_tools:$PATH
```

For Zsh, add this to `~/.zshrc`:

```bash
export PATH=/path/to/depot_tools:$PATH
```

Then reload your shell configuration:

```bash
source ~/.bashrc
```

or:

```bash
source ~/.zshrc
```

Check that the required commands are available:

```bash
which fetch
which gclient
which gn
which autoninja
```

---

## Script Usage

Make the script executable:

```bash
chmod +x build_v8_d8.sh
```

Build a release version of `d8`:

```bash
./build_v8_d8.sh <v8-commit-hash>
```

Example:

```bash
./build_v8_d8.sh 350e0f7997fdb936510ecc6132e84533393c5066
```

Build a coverage-enabled version of `d8`:

```bash
./build_v8_d8.sh <v8-commit-hash> --coverage-on
```

Example:

```bash
./build_v8_d8.sh 350e0f7997fdb936510ecc6132e84533393c5066 --coverage-on
```

---

## What the Script Does

Given a V8 commit hash, the script:

1. Creates a parent directory using the first 11 characters of the commit hash.

   Example:

   ```text
   v8_350e0f7997f
   ```

2. Runs:

   ```bash
   fetch v8
   ```

3. Renames the fetched V8 source directory.

   Example:

   ```text
   v8 -> v8_350e0f7997f
   ```

4. Updates `.gclient` so that `gclient sync` uses the renamed directory.

5. Checks out the requested commit.

6. Runs:

   ```bash
   gclient sync
   ```

7. Applies a workaround for possible `GLIBCXX_3.4.30` errors by moving aside V8's bundled `libstdc++.so.6`.

8. Writes GN build arguments.

9. Runs:

   ```bash
   gn gen <output-directory>
   ```

10. Builds `d8` using:

```bash
autoninja -C <output-directory> d8
```

---

## Output Directories

For a release build:

```text
out/x64.release
```

For a coverage build:

```text
out/x64.coverage
```

The final binary should be located at:

```text
out/x64.release/d8
```

or:

```text
out/x64.coverage/d8
```

---

## Coverage Build

To enable coverage, pass:

```bash
--coverage-on
```

The script then uses the following GN options:

```gn
is_debug = true
is_clang = true
use_clang_coverage = true
```

Example:

```bash
./build_v8_d8.sh 350e0f7997fdb936510ecc6132e84533393c5066 --coverage-on
```

---

## Notes on Python

Some older V8 and `depot_tools` scripts expect the command:

```bash
python
```

If your system only provides:

```bash
python2
```

the script creates a local shim:

```text
~/pyshim/python -> python2
```

and temporarily adds it to `PATH`.

---

## Notes on the `GLIBCXX_3.4.30` Error

When building older versions of V8 on newer Linux systems, you may see an error like:

```text
libstdc++.so.6: version `GLIBCXX_3.4.30' not found
required by /lib/x86_64-linux-gnu/libicuuc.so.74
```

This happens when an older bundled `libstdc++.so.6` is mixed with a newer system ICU library.

The script works around this by moving aside:

```text
third_party/llvm-build/Release+Asserts/lib/libstdc++.so.6
```

so the build can use the system `libstdc++`.

---

## Checking the Built Binary

After the build finishes, you can check the binary:

```bash
./out/x64.release/d8 --version
```

or for coverage:

```bash
./out/x64.coverage/d8 --version
```

You can also check which `libstdc++` is used:

```bash
ldd out/x64.release/d8 | grep stdc++
```

The expected result should point to the system library, for example:

```text
/usr/lib/x86_64-linux-gnu/libstdc++.so.6
```
