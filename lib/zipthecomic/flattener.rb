# frozen_string_literal: true

require "fileutils"
require "pathname"

module Zipthecomic
  # Flattens a directory by moving all .cbr/.cbz files into its root
  class Flattener
    # @param directory [String] the root directory to flatten
    # @param options [Hash] CLI options (:type, :strategy, :prune)
    def initialize(directory, options = {})
      @directory = File.expand_path(directory)
      @type = options[:type] || "cbz"
      @strategy = options[:strategy] || "rename"
      @prune = options[:prune] || false
      @prune_dry_run = options[:prune_dry_run] || false
      @logger = Zipthecomic.setup_logger(File.expand_path("../../log/zipthecomic.log", __dir__))
    end

    # Run the flattening process
    def run
      patterns = {
        "cbz" => "**/*.cbz",
        "cbr" => "**/*.cbr",
        "all" => "**/*.{cbz,cbr}"
      }

      glob_pattern = File.join(@directory, patterns[@type])
      files = Dir.glob(glob_pattern).uniq
      moved = 0
      skipped = 0
      overwritten = 0

      files.each do |file|
        filename = File.basename(file)
        dest_path = File.join(@directory, filename)

        # Already at destination
        next if file == dest_path

        if File.exist?(dest_path)
          case @strategy
          when "overwrite"
            FileUtils.mv(file, dest_path, force: true)
            @logger.warn("Overwrote: #{dest_path}")
            overwritten += 1

          when "rename"
            base = File.basename(filename, File.extname(filename))
            ext = File.extname(filename)
            count = 1
            new_name = "#{base} (#{count})#{ext}"
            new_path = File.join(@directory, new_name)

            while File.exist?(new_path)
              count += 1
              new_name = "#{base} (#{count})#{ext}"
              new_path = File.join(@directory, new_name)
            end

            FileUtils.mv(file, new_path)
            @logger.info("Renamed and moved: #{new_path}")
            moved += 1

          when "skip"
            @logger.warn("Skipped (name conflict): #{filename}")
            skipped += 1
            next

          else
            @logger.error("Unknown strategy: #{@strategy}")
            skipped += 1
            next
          end
        else
          FileUtils.mv(file, dest_path)
          @logger.info("Moved: #{dest_path}")
          moved += 1
        end
      end

      puts "\nFlatten Summary:"
      puts "  Moved:       #{moved}"
      puts "  Skipped:     #{skipped}"
      puts "  Overwritten: #{overwritten}" if @strategy == "overwrite"
      puts

      @logger.info("Flattening complete.")

      prune_empty_dirs if @prune || @prune_dry_run
    end

    private

    # Recursively show and/or remove empty directories under the base directory
    #
    # @return [void]
    def prune_empty_dirs
      @logger.info("Checking for empty directories under #{@directory}...")

      deleted = 0
      simulated = 0

      Dir.glob(File.join(@directory, "**/")).sort_by { |d| -d.length }.each do |dir|
        next if dir == @directory
        begin
          if Dir.empty?(dir)
            if @prune_dry_run
              @logger.info("[dry-run] Would remove: #{dir}")
              simulated += 1
            end
            if @prune
              Dir.rmdir(dir)
              @logger.info("Removed empty folder: #{dir}")
              deleted += 1
            end
          end
        rescue => e
          @logger.warn("Could not remove folder #{dir}: #{e.message}")
        end
      end

      puts "\nPrune Summary:"
      puts "  Would remove: #{simulated} folder#{"s" if simulated != 1}" if @prune_dry_run
      puts "  Actually removed: #{deleted} folder#{"s" if deleted != 1}" if @prune
      puts
    end
  end
end
