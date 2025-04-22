# 🛠 zipthecomic Development Guide

This document describes the internal structure, code organization, and guidelines for contributing to zipthecomic.

---

## 🌳 Project Structure

```
zipthecomic/
├── bin/
│   └── zipthecomic            # Executable CLI entrypoint
├── lib/
│   ├── zipthecomic/
│   │   ├── cli.rb             # CLI commands using Thor
│   │   ├── converter.rb       # Conversion logic
│   │   ├── flattener.rb       # Flatten logic
│   │   └── logger_setup.rb    # Logger configuration
│   └── zipthecomic.rb         # Main require entrypoint
├── log/
│   └── zipthecomic.log        # Output logs
├── spec/
│   └── ...                    # (Coming soon) Tests for all functionality
├── Gemfile                    # Ruby dependencies
├── README.md                  # User-facing documentation
├── DEVELOPMENT.md             # You're reading this
└── .gitignore                 # Git ignore rules
```

---

## 🧩 File Descriptions

### `bin/zipthecomic`

Entrypoint for CLI. Runs the Thor-based command-line interface.

### `lib/zipthecomic/cli.rb`

Defines commands like `convert` and `flatten`, their options, and descriptions using Thor.

### `lib/zipthecomic/converter.rb`

Handles all logic related to converting `.cbr` files to `.cbz`, including:

- Progress tracking
- Logging
- Replace/delete behavior
- Flatten output during conversion

#### ComicInfo.xml Handling

If a `ComicInfo.xml` file exists in the original `.cbr` archive (as is common with files tagged by ComicTagger or similar tools), it is automatically preserved and included in the new `.cbz` archive.

If no such file exists, a default `ComicInfo.xml` is generated with basic title and summary information based on the filename.

A message indicating whether the metadata was preserved or generated is logged to both the log file and the terminal during conversion.

### `lib/zipthecomic/flattener.rb`

Handles flattening of directory structure for `.cbr`/`.cbz` files:

- Works as a standalone command
- Supports multiple collision strategies
- Supports both `--prune` and `--prune-dry-run` simultaneously
- Integrates with logger

### `lib/zipthecomic/logger_setup.rb`

Sets up multi-output logging (file + terminal) using a `MultiLogger` wrapper class.

---

## 🧪 Testing (Planned)

We will use:

- `RSpec` for testing
- `SimpleCov` for code coverage
- `fakefs` for isolated file testing

All specs will go in the `spec/` directory with `spec_helper.rb` and `.rspec` config.

---

## 🗺️ Roadmap (Planned Features)

- Add support for repacking/optimizing `.cbz` files, while maintaining the original file structure and metadata

---

## 🧱 Contributing

We welcome contributions and pull requests!

### Common types of contributions:

- 💡 Feature additions (e.g. new CLI options)
- 🐛 Bug fixes or better edge-case handling
- 🧼 Code cleanup, YARD documentation
- 🧪 Test specs

---

### How to contribute

1. Fork and clone the repository
2. Create a feature branch:
   ```bash
   git checkout -b my-feature
   ```
3. Make your changes with clear commits
4. Run tests (when available):
   ```bash
   bundle exec rspec
   ```
5. Push to your fork:
   ```bash
   git push origin my-feature
   ```
6. Open a pull request 🎉

---

## ✍️ Code Style

- Use `standard` for automatic Ruby linting and formatting
  ```bash
  bundle exec standardrb
  ```
- Log using the provided logger instead of `puts`
- Use **YARD format** for documenting methods

Example YARD format:

```ruby
# Moves all files to a single directory and handles naming collisions.
#
# @return [void]
def flatten_output
  ...
end
```

---

## 🧰 Tooling Wishlist (Optional for contributors)

- Github Actions for CI/CD

---

## 📖 License

This project is licensed under the [MIT License](./LICENSE) © 2025 Jared Wolf
