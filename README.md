# 📚 zipthecomic

![Ruby](https://img.shields.io/badge/Ruby-3.2-red)
![Thor](https://img.shields.io/badge/Built%20with-Thor-yellow?logo=rubygems&logoColor=yellow)
![License](https://img.shields.io/badge/License-MIT-blue)
<!-- ![License](https://img.shields.io/github/license/jaredaidenwolf/zipthecomic) -->

**zipthecomic** is a command-line tool for batch-converting `.cbr` comic book archives to `.cbz`, while preserving existing metadata. There are also options to flatten folder structures, and generally clean up your comic book library.

> 🧑‍💻 This CLI tool is designed for **macOS** (tested with Homebrew) and is **likely to work on Linux** as well. Windows is not currently supported.

Built in Ruby, powered by Thor, and ready to be extended or integrated into larger projects.

---

## 🚀 Installation

### Prerequisites

Install `rar` to handle `.cbr` file extraction:

```bash
brew install rar
```

### Clone the repository and install dependencies

```bash
git clone https://github.com/jaredaidenwolf/zipthecomic
cd zipthecomic
bundle install
```

Make the CLI executable:

```bash
chmod +x bin/zipthecomic
```

---

## 🧑‍💻 Usage

### 🔄 `convert` Command

```bash
bin/zipthecomic convert <source_dir> <destination_dir> [options]
```

- Converts `.cbr` files to `.cbz`
- Supports post-processing and cleanup
- Respects nested folder structure unless flattened

#### Options

| Option             | Description                                                                 | Default |
|--------------------|-----------------------------------------------------------------------------|---------|
| `--dry-run`        | Simulate the conversion without file changes                                | `false` |
| `--delete`         | Prompt to delete original `.cbr` files after conversion                     | `false` |
| `--replace`        | Prompt to replace `.cbr` with `.cbz` in the same location                   | `false` |
| `--force-replace`  | **Immediately** replace `.cbr` with `.cbz` (no prompt)                      | `false` |
| `--flatten=[mode]` | Flatten output into a single folder after conversion. Strategies: `overwrite`, `rename`, `skip` | _none_ |

#### Examples

**Basic conversion:**

```bash
bin/zipthecomic convert comics converted_comics
```

**Convert and flatten all output with renaming on conflict:**

```bash
bin/zipthecomic convert comics output --flatten=rename
```

**Convert and prompt to replace originals:**

```bash
bin/zipthecomic convert comics output --replace
```

**Convert and immediately replace originals (no prompt):**

```bash
bin/zipthecomic convert comics output --force-replace
```

---

### 🔖 Metadata Preservation

If your `.cbr` files contain a `ComicInfo.xml` file (commonly created by tools like ComicTagger), **zipthecomic will automatically preserve and transfer it** into the resulting `.cbz` file.

If no metadata file is found, a simple one will be generated based on the file name.

---

### 📦 `flatten` Command

```bash
bin/zipthecomic flatten <directory> [options]
```

- Flattens a folder by moving `.cbz` and/or `.cbr` files to the root
- Useful for organizing comics into a single folder
- Supports simultaneous use of `--prune` and `--prune-dry-run` for safety and automation

#### Options

| Option              | Description                                                              | Default |
|---------------------|--------------------------------------------------------------------------|---------|
| `--type`            | File type to flatten (`cbz`, `cbr`, or `all`)                            | `cbz`   |
| `--strategy`        | Collision strategy (`rename`, `overwrite`, `skip`)                       | `rename` |
| `--prune`           | Remove empty directories after files are moved                          | `false` |
| `--prune-dry-run`   | Show which folders would be removed without actually deleting them       | `false` |

#### Examples

**Flatten all `.cbz` files with renaming if needed:**

```bash
bin/zipthecomic flatten comics --type=cbz --strategy=rename
```

**Flatten `.cbr` files and overwrite duplicates:**

```bash
bin/zipthecomic flatten comics --type=cbr --strategy=overwrite
```

**Flatten everything but skip on conflict:**

```bash
bin/zipthecomic flatten comics --type=all --strategy=skip
```

**Flatten and clean up empty folders:**

```bash
bin/zipthecomic flatten comics --type=all --strategy=rename --prune
```

**Preview folders that would be deleted without actually deleting them:**

```bash
bin/zipthecomic flatten comics --prune-dry-run
```

**Do both prune and simulate in the same run:**

```bash
bin/zipthecomic flatten comics --type=all --prune --prune-dry-run
```

---

### ☢️ `nuke` Command (Destructive)

```bash
bin/zipthecomic nuke <directory>
```

> ⚠️ **WARNING:** This command is fully automated and destructive. It:
> - Flattens all `.cbz`/`.cbr` files
> - Deletes empty directories
> - Converts `.cbr` files to `.cbz`
> - Replaces all originals with no prompts

This is intended for automation and cleanup pipelines where human confirmation is not required.

#### Example

```bash
bin/zipthecomic nuke comics
```

💣 You're not just zipping the comic — you're nuking the folder structure.

---

## 📖 Logging & Output

- Logs are saved to `log/zipthecomic.log`
- Console output includes spinners and status summaries
- Cleanly shows converted, skipped, failed, and flattened files

---

## 🛣️ Roadmap & Planned Features

- [ ] RSpec + SimpleCov test suite
- [ ] Image optimization (e.g., WebP conversion during `.cbz` creation)

See [`DEVELOPMENT.md`](./DEVELOPMENT.md) for more roadmap details.

---

## 🤝 Contributions

Pull requests and feature suggestions are very welcome!

See [`DEVELOPMENT.md`](./DEVELOPMENT.md) for detailed development and contribution instructions.

---

## 📜 License

This project is licensed under the [MIT License](./LICENSE).
