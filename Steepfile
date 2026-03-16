# frozen_string_literal: true

target :lib do
  signature "sig"
  check "lib"

  configure_code_diagnostics(Steep::Diagnostic::Ruby.strict)

  library "pathname"
  library "securerandom"
  library "stringio"
  library "uri"
end
