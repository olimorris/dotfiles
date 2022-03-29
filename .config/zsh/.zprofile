# Add Homebrew to PATH (required for M1 Macs)
eval $(/opt/homebrew/bin/brew shellenv)

# MacOS ships with an older version of Ruby which is built against an X86
# system rather than ARM i.e. for M1+. So replace the system ruby with an
# updated one from Homebrew and ensure it is before /usr/bin/ruby
# Prepend to PATH
path=(
  "$(brew --prefix)/opt/ruby/bin"
  "$(brew --prefix)/lib/ruby/gems/3.1.0/bin"
  # NOTE: Add coreutils which make commands like ls run as they do on Linux rather than the BSD flavoured variant macos ships with
  "$(brew --prefix)/opt/coreutils/libexec/gnubin"
  $path
)
