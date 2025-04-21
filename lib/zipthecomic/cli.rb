# frozen_string_literal: true

require "thor"

module Zipthecomic
  # CLI interface for Zipthecomic using Thor.
  class CLI < Thor
    desc "convert SOURCE DEST", "Convert .cbr comic files to .cbz"
    method_option :dry_run, type: :boolean, default: false, desc: "Run without actual conversion"
    method_option :delete, type: :boolean, default: false, desc: "Prompt to delete original files after conversion"
    method_option :replace, type: :boolean, default: false, desc: "Replace original .cbr files with converted .cbz files"
    method_option :force_replace, type: :boolean, default: false, desc: "Immediately delete .cbr and replace with .cbz in source dir (no prompt)"
    method_option :flatten, type: :string, enum: %w[overwrite rename skip], desc: "Move all .cbz files into a single output folder (choose: overwrite, rename, skip on conflict)"
    method_option :prune, type: :boolean, default: false, desc: "Remove empty directories after flattening"
    method_option :prune_dry_run, type: :boolean, default: false, desc: "Show which folders would be removed by --prune without deleting them"

    # Exit on failure
    def self.exit_on_failure?
      true
    end

    # Convert CBR files in SOURCE directory to CBZ in DEST directory.
    #
    # @param source [String] source directory path
    # @param dest [String] destination directory path
    def convert(source, dest)
      converter = Converter.new(source, dest, options)
      converter.run
    end

    # Flatten all .cbr/.cbz files into a single folder
    #
    # @param directory [String] directory path
    desc "flatten DIRECTORY", "Move all .cbz/.cbr files into DIRECTORY root"
    method_option :type, type: :string, default: "cbz", enum: %w[cbz cbr all], desc: "File type to flatten"
    method_option :strategy, type: :string, default: "rename", enum: %w[rename overwrite skip], desc: "Collision strategy"
    method_option :prune, type: :boolean, default: false, desc: "Remove empty directories after flattening"
    method_option :prune_dry_run, type: :boolean, default: false, desc: "Simulate which folders would be removed"
    def flatten(directory)
      require_relative "flattener"
      Zipthecomic::Flattener.new(directory, options).run
    end

    # Flatten, prune, convert, and replace all .cbr files with .cbz (no prompts)
    #
    # @param directory [String] directory path
    desc "nuke DIRECTORY", "Flatten, prune, convert, and replace all .cbr files with .cbz (no prompts)"
    def nuke(directory)
      require_relative "flattener"
      require_relative "converter"
      require_relative "logger_setup"

      puts "\n#{set_color("=== ☢️  NUKE MODE ENGAGED  ☢️ ===", :red, :bold)}\n\n"

      logger = Zipthecomic.setup_logger(File.expand_path("../../log/zipthecomic.log", __dir__))

      # Step 1: Flatten and prune
      say_status "NUKE", "Flattening folder structure...", :yellow
      Zipthecomic::Flattener.new(directory, {
        type: "all",
        strategy: "rename",
        prune: true
      }).run

      # Step 2: Create temp folder for conversion
      temp_dir = File.join(directory, "converted_temp")
      FileUtils.mkdir_p(temp_dir) unless Dir.exist?(temp_dir)
      say_status "NUKE", "Using temp folder for conversion: #{temp_dir}", :yellow

      # Step 3: Convert and replace
      say_status "NUKE", "Converting and replacing .cbr files...", :yellow
      Zipthecomic::Converter.new(directory, temp_dir, {
        flatten: "rename",
        force_replace: true
      }).run

      # Step 4: Clean up the temp folder
      if Dir.exist?(temp_dir)
        say_status "NUKE", "Cleaning up temp folder: #{temp_dir}", :yellow
        FileUtils.rm_rf(temp_dir)
      end

      logger.info("=== ☢️  NUKE MODE COMPLETE  ☢️ ===")
    end
  end
end
