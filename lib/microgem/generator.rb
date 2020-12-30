#!/usr/bin/env ruby

require 'thor'
require 'json'

class Microgem::Generator < Thor::Group
  include Thor::Actions

  def self.source_root
    File.dirname(__FILE__) + '/../../template/'
  end

  argument :name
  class_option :version, default: "0.1.0"
  class_option :info, default: "TODO"
  class_option :specs, default: true, type: :boolean
  class_option :class, default: false, type: :boolean
  class_option :github

  attr_reader :settings

  def load_settings
    dotfile_path = File.expand_path("~/.microgem")
    if File.exist? dotfile_path
      @settings = JSON.load File.read(dotfile_path)
    else
      @settings = {}
      say "This is your first microgem. Please tell me who you are!"
      guess_author = `git config user.name`.chomp
      guess_author = nil if guess_author.empty?
      guess_email  = `git config user.email`.chomp
      guess_email = nil if guess_email.empty?
      guess_github = `git config github.user`.chomp
      guess_github = nil if guess_github.empty?
      @settings["author"]  = ask("Your Name" + (guess_author ? " [#{guess_author}]:" : ":"))
      @settings["author"] = guess_author if @settings["author"].empty? && guess_author
      @settings["email"]   = ask("Your E-Mail" + (guess_email ? " [#{guess_email}]:" : ":")) || guess_email
      @settings["email"] = guess_email if @settings["email"].empty? && guess_email
      @settings["website"] = ask("Your Website:")
      @settings["github"]  = ask("Your GitHub Name" + (guess_github ? " [#{guess_github}]:" : ":")) || guess_github
      @settings["github"] = guess_github if @settings["github"].empty? && guess_github
      File.write dotfile_path, JSON.dump(@settings)
    end
  end

  def validate_name
    unless name =~ /\A[A-Z0-9_-]+\z/i
      raise ArgumentError, "invalid gem name: must only contain A-Z, 0-9, _ or -"
    end
    if module_name =~ /::[^A-Z]/
      raise ArgumentError, "invalid gem name: module names only allowed to start with A-Z"
    end
  end

  # - - -

  def module_def(index=nil)
    options[:class] && index && sub_modules.size == index + 1 ? "class" : "module"
  end

  def module_name
    name.gsub(/-[_-]*(?![_-]|$)/){ '::' }.gsub(/(^?[_-]+|(?<=:)|^)(.|$)/){ $2.upcase }
  end

  def sub_modules
    module_name.split '::'
  end

  def path
    name.gsub(/-[_-]*(?![_-]|$)/){ '/' }
  end

  def spec_name
    name.gsub(/-[_-]*(?![_-]|$)/){ '_' }
  end

  def last_name
    path[%r<[^/]+$>]
  end

  def specs
    options[:specs]
  end

  def github_name
    options[:github] || name
  end

  def info
    options[:info]
  end

  def version
    options[:version]
  end

  def current_year
    Date.today.year
  end

  def generate
    directory ".", name,  exclude_pattern: %r<_spec.rb|Gemfile|\.github>
    if options[:specs]
      directory "spec", name + "/spec"
      directory ".github", name + "/.github"
      copy_file "Gemfile", name + "/Gemfile"
    end
  end
end
