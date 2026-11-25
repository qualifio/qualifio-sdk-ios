# frozen_string_literal: true

# Switches Package.swift between the released binary on the CDN and a local build of the SDK.
#
#   ruby scripts/spm.rb local       # build QualifioKit.xcframework from this checkout and point Package.swift to it
#   ruby scripts/spm.rb remote      # point Package.swift back to the released binary on the CDN
#   ruby scripts/spm.rb status      # show what Package.swift points to
#
# Options for `local`:
#   --release           build with the Release configuration (default: Debug)
#   --simulator-only    skip the device slice for faster builds
#
# Run `local` again after each change to rebuild the XCFramework.
# Never commit Package.swift while it points to a local build.

require 'fileutils'
require 'json'
require 'open3'

$stdout.sync = true

ROOT = File.expand_path('..', __dir__)
MANIFEST = File.join(ROOT, 'Package.swift')
LOCAL_DIR = File.join(ROOT, '.local')
LOCAL_XCFRAMEWORK = '.local/QualifioKit.xcframework'
LOCAL_INFO = File.join(LOCAL_DIR, 'build.json')
SCHEME = 'QualifioKit'

# Matches the binary target location, either remote (url + checksum) or local (path).
REMOTE_PATTERN = /url:\s*"(?<url>[^"]+)",\s*checksum:\s*"(?<checksum>[^"]+)"/.freeze
LOCAL_PATTERN = /path:\s*"#{Regexp.escape(LOCAL_XCFRAMEWORK)}"/.freeze

def info(message)
  puts "\e[36m▸ #{message}\e[0m"
end

def success(message)
  puts "\e[32m✔ #{message}\e[0m"
end

def fail!(message)
  warn "\e[31m✘ #{message}\e[0m"
  exit 1
end

def run!(*command)
  output, status = Open3.capture2e(*command, chdir: ROOT)
  fail!("Command failed: #{command.join(' ')}\n#{output}") unless status.success?
  output
end

def manifest
  File.read(MANIFEST)
end

def local?
  manifest.match?(LOCAL_PATTERN)
end

# Local build

def build_slice(configuration, destination, sdk)
  info "Building #{SCHEME} (#{configuration}, #{sdk})"

  run!(
    'xcodebuild', 'build',
    '-workspace', 'Qualifio.xcworkspace',
    '-scheme', SCHEME,
    '-configuration', configuration,
    '-destination', destination,
    '-sdk', sdk,
    '-derivedDataPath', File.join(LOCAL_DIR, 'DerivedData'),
    '-skipPackagePluginValidation',
    '-skipMacroValidation',
    '-quiet',
    'BUILD_LIBRARY_FOR_DISTRIBUTION=YES',
    'CODE_SIGNING_ALLOWED=NO'
  )

  File.join(LOCAL_DIR, 'DerivedData/Build/Products', "#{configuration}-#{sdk}", "#{SCHEME}.framework")
end

def git_info
  {
    branch: run!('git', 'rev-parse', '--abbrev-ref', 'HEAD').strip,
    commit: run!('git', 'rev-parse', '--short', 'HEAD').strip,
    dirty: !run!('git', 'status', '--porcelain', '--', 'QualifioKit').strip.empty?,
  }
end

def use_local(options)
  configuration = options.include?('--release') ? 'Release' : 'Debug'
  FileUtils.mkdir_p(LOCAL_DIR)

  slices = []
  slices << build_slice(configuration, 'generic/platform=iOS', 'iphoneos') unless options.include?('--simulator-only')
  slices << build_slice(configuration, 'generic/platform=iOS Simulator', 'iphonesimulator')

  info 'Creating XCFramework'
  xcframework = File.join(ROOT, LOCAL_XCFRAMEWORK)
  FileUtils.rm_rf(xcframework)
  run!('xcodebuild', '-create-xcframework', *slices.flat_map { |slice| ['-framework', slice] }, '-output', xcframework)

  File.write(LOCAL_INFO, JSON.pretty_generate({ configuration: configuration, built_at: Time.now }.merge(git_info)))

  unless local?
    contents = manifest
    fail!('Unable to find the url and checksum of the binary target in Package.swift.') unless contents.match?(REMOTE_PATTERN)

    File.write(MANIFEST, contents.sub(REMOTE_PATTERN, "path: \"#{LOCAL_XCFRAMEWORK}\""))
  end

  success "Package.swift now points to the local build (#{configuration})."
  puts '  If a consuming app keeps running the previous build, clean its build folder (Shift+Cmd+K).'
  puts '  Run `ruby scripts/spm.rb remote` before committing.'
end

# Remote

def use_remote
  unless local?
    success 'Package.swift already points to the released binary.'
    return
  end

  committed, status = Open3.capture2e('git', 'show', 'HEAD:Package.swift', chdir: ROOT)
  fail!("Unable to read the committed Package.swift.\n#{committed}") unless status.success?

  remote = committed.match(REMOTE_PATTERN)
  fail!('The committed Package.swift does not point to a released binary. Restore it manually.') unless remote

  File.write(MANIFEST, manifest.sub(LOCAL_PATTERN, "url: \"#{remote[:url]}\",\n            checksum: \"#{remote[:checksum]}\""))
  FileUtils.rm_rf(File.join(ROOT, LOCAL_XCFRAMEWORK))
  FileUtils.rm_f(LOCAL_INFO)

  success "Package.swift now points to #{remote[:url]}."
end

# Status

def status
  unless local?
    url = manifest.match(REMOTE_PATTERN)&.[](:url)
    puts url ? "Released binary: #{url}" : 'Unknown: unable to find the binary target in Package.swift.'
    return
  end

  unless File.exist?(LOCAL_INFO)
    puts 'Local build (no build information found, run `ruby scripts/spm.rb local` again)'
    return
  end

  build = JSON.parse(File.read(LOCAL_INFO))
  dirty = build['dirty'] ? ', with uncommitted changes' : ''
  puts "Local build: #{build['branch']} @ #{build['commit']}#{dirty} (#{build['configuration']}, built #{build['built_at']})"
end

# Entry point

def usage
  puts File.read(__FILE__).lines.drop(2).take_while { |line| line.start_with?('#') }.map { |line| line.sub(/^# ?/, '') }
  exit 1
end

command, *options = ARGV
case command
when 'local' then use_local(options)
when 'remote' then use_remote
when 'status' then status
else usage
end
