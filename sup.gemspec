lib = File.expand_path("../lib", __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'sup/version'

# Files
SUP_EXECUTABLES = %w(sup sup-add sup-config sup-dump sup-import-dump
  sup-recover-sources sup-sync sup-sync-back sup-tweak-labels
  sup-migrate-index)
SUP_EXTRA_FILES = %w(CONTRIBUTORS README.txt LICENSE History.txt ReleaseNotes)
SUP_FILES =
  SUP_EXTRA_FILES +
  SUP_EXECUTABLES.map { |f| "bin/#{f}" } +
  Dir["lib/**/*.rb"]


module Redwood
  Gemspec = Gem::Specification.new do |s|
    s.name = "sup"
    s.version = ENV["REL"] || (::Redwood::VERSION == "git" ? "999" : ::Redwood::VERSION)
    s.date = Time.now.strftime "%Y-%m-%d"
    s.authors = ["William Morgan", "Gaute Hope", "Hamish Downer", "Matthieu Rakotojaona"]
    s.email   = "sup-talk@rubyforge.org"
    s.summary = "A console-based email client with the best features of GMail, mutt and Emacs"
    s.homepage = "https://github.com/sup-heliotrope/sup/wiki"
    s.description = <<-DESC
      Sup is a console-based email client for people with a lot of email.

      - Handling mail from multiple mbox and Maildir sources
      - GMail-like archiving and tagging
      - Blazing fast full-text search with a rich query language
      - Multiple accounts - pick the right one when sending mail
      - Ruby-programmable hooks
      - Automatically tracking recent contacts
DESC
    s.files = SUP_FILES
    s.executables = SUP_EXECUTABLES

    s.add_dependency "xapian-full-alaveteli", "~> 1.2"
    s.add_dependency "ncursesw-sup", "~> 1.3", ">= 1.3.1"
    s.add_dependancy "mail", "~> 2.5"
    s.add_dependency "highline"
    s.add_dependency "trollop", ">= 1.12"
    s.add_dependency "lockfile"
    s.add_dependency "mime-types", "~> 1"
    s.add_dependency "gettext"

    s.add_development_dependency "bundler", "~> 1.3"
    s.add_development_dependency "rake"
  end
end
