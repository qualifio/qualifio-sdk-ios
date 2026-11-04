# frozen_string_literal: true

require 'fileutils'

# Builder service to automate the whole build process.
class Bob
  attr_reader :version

  def initialize
    unless ARGV.empty?
      @version = ARGV[0]
      return
    end

    puts <<~DESC
      Missing version argument.

      To run the command use:
      ruby scripts/build.rb 1.0.0
    DESC

    exit 1
  end

  def work
    puts "▸ Building version #{version}".cyan

    prepare_environment

    puts '▸ Cleaning...'.cyan
    Xcode.clean

    puts '▸ Building...'.cyan
    Xcode.build

    puts '▸ Generating SPM artefacts...'.cyan
    SPM.new(version).generate_artefacts

    puts '▸ Done! 🚀'.cyan
  end

  class << self
    def zip(working_directory:, files:, output:)
      system("cd #{working_directory} && zip -rq #{output} #{files}", exception: true)
    end
  end

  private

  def prepare_environment
    if ENV['NOTIFICARE_SDK_DISTRIBUTION_CERTIFICATE'].to_s.strip.empty?
      puts 'Unable to find the code signing certificate information.'.red
      exit 1
    end

    FileUtils.rm_rf '.build'
    FileUtils.mkdir_p '.build/archives'
    FileUtils.mkdir_p '.build/intermediates'
    FileUtils.mkdir_p '.build/outputs'
    FileUtils.mkdir_p '.build/tmp'
  end
end

# Utility to enumerate the buildable modules.
class Framework
  attr_reader :scheme, :spm_zip_filename, :spm_checksum_placeholder

  def initialize(scheme:, spm_zip_filename:, spm_checksum_placeholder:)
    @scheme = scheme
    @spm_zip_filename = spm_zip_filename
    @spm_checksum_placeholder = spm_checksum_placeholder
  end

  class << self
    def all
      [
        Framework.new(scheme: 'QualifioKit',
                      spm_zip_filename: 'spm-qualifio.zip',
                      spm_checksum_placeholder: '{{QUALIFIO_CHECKSUM}}'),
      ]
    end
  end
end

# Utility run xcodebuild tasks.
class Xcode
  class << self
    def clean
      Framework.all.each do |framework|
        puts "▸ Cleaning #{framework.scheme}".green

        command = <<~COMMAND
          xcodebuild clean \\
            -workspace Qualifio.xcworkspace \\
            -scheme #{framework.scheme} \\
            -destination "generic/platform=iOS" \\
            -sdk iphoneos \\
            -quiet
        COMMAND

        system(command, exception: true)
      end
    end

    def build
      Framework.all.each do |framework|
        puts "▸ Building #{framework.scheme}".green

        create_ios_device_archive(framework)
        create_ios_simulator_archive(framework)
        create_xcframework(framework)
        sign_xcframework(framework)
      end
    end

    private

    def create_ios_device_archive(framework)
      puts "▸ Creating #{framework.scheme} iOS device archive".green

      command = <<~COMMAND
        xcodebuild archive \\
          -workspace Qualifio.xcworkspace \\
          -scheme #{framework.scheme} \\
          -archivePath ".build/archives/#{framework.scheme}-iOS.xcarchive" \\
          -destination "generic/platform=iOS" \\
          -configuration Release \\
          -sdk iphoneos \\
          -quiet \\
          SKIP_INSTALL=NO \\
          BUILD_LIBRARY_FOR_DISTRIBUTION=YES
      COMMAND

      system(command, exception: true)
    end

    def create_ios_simulator_archive(framework)
      puts "▸ Creating #{framework.scheme} iOS simulator archive".green

      command = <<~COMMAND
        xcodebuild archive \\
          -workspace Qualifio.xcworkspace \\
          -scheme #{framework.scheme} \\
          -archivePath ".build/archives/#{framework.scheme}-iOS-simulator.xcarchive" \\
          -destination "generic/platform=iOS Simulator" \\
          -configuration Release \\
          -sdk iphonesimulator \\
          -quiet \\
          SKIP_INSTALL=NO \\
          BUILD_LIBRARY_FOR_DISTRIBUTION=YES
      COMMAND

      system(command, exception: true)
    end

    def create_xcframework(framework)
      puts "▸ Creating #{framework.scheme} XCFramework".green

      command = <<~COMMAND
        xcodebuild -create-xcframework \\
          -framework ".build/archives/#{framework.scheme}-iOS.xcarchive/Products/Library/Frameworks/#{framework.scheme}.framework" \\
          -debug-symbols #{File.expand_path(".build/archives/#{framework.scheme}-iOS.xcarchive/dSYMs/#{framework.scheme}.framework.dSYM")} \\
          -framework ".build/archives/#{framework.scheme}-iOS-simulator.xcarchive/Products/Library/Frameworks/#{framework.scheme}.framework" \\
          -debug-symbols #{File.expand_path(".build/archives/#{framework.scheme}-iOS-simulator.xcarchive/dSYMs/#{framework.scheme}.framework.dSYM")} \\
          -output ".build/intermediates/#{framework.scheme}.xcframework"
      COMMAND

      system(command, exception: true)
    end

    def sign_xcframework(framework)
      puts "▸ Signing #{framework.scheme} XCFramework".green

      command = <<~COMMAND
        codesign --timestamp -v \\
          --sign "$NOTIFICARE_SDK_DISTRIBUTION_CERTIFICATE" \\
          ".build/intermediates/#{framework.scheme}.xcframework"

      COMMAND

      system(command, exception: true)
    end
  end
end

# Utility to prepare SPM artefacts.
class SPM
  def initialize(version)
    @version = version
  end

  def generate_artefacts
    Framework.all.each do |framework|
      create_zip_file(framework)
      create_checksum_file(framework)
    end

    create_config_file
  end

  private

  def create_zip_file(framework)
    FileUtils.cp_r ".build/intermediates/#{framework.scheme}.xcframework", '.build/tmp'
    Bob.zip(working_directory: '.build/tmp',
            files: "#{framework.scheme}.xcframework",
            output: "../outputs/#{framework.spm_zip_filename}")
  end

  def create_config_file
    config_file = File.read '.github/templates/Package.swift'
    config_file = config_file.gsub(/{{(.*?)}}/) do |key|
      if key == '{{VERSION}}'
        @version
      else
        framework = Framework.all.find { |f| f.spm_checksum_placeholder == key }
        calculate_checksum(framework)
      end
    end

    File.write 'Package.swift', config_file
  end

  def calculate_checksum(framework)
    `swift package compute-checksum .build/outputs/#{framework.spm_zip_filename}`.strip
  end

  def create_checksum_file(framework)
    File.write ".build/outputs/#{framework.spm_zip_filename}.checksum.txt", calculate_checksum(framework)
  end
end

class String
  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def cyan
    colorize(36)
  end

  private

  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end
end

#
# Do the work. 🛠️
#
Bob.new.work
