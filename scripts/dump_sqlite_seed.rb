#!/usr/bin/env ruby
# frozen_string_literal: true

require "sqlite3"
require "fileutils"

SOURCE = ARGV[0] || "db/development.sqlite"
DEST = ARGV[1] || "db/seeds/development.sql"

db = SQLite3::Database.new(SOURCE)
db.results_as_hash = true

def blank_to_nil(value)
  return nil if value.nil? || value == ""

  value
end

def pg_escape(value)
  return "NULL" if value.nil?

  "'" + value.to_s.gsub("'", "''") + "'"
end

def bool_or_null(value)
  return "NULL" if value.nil? || value == ""

  value.to_i == 1 || value == true || value == "t" || value == "true" ? "TRUE" : "FALSE"
end

def num_or_null(value)
  return "NULL" if value.nil? || value == ""

  value.to_s
end

out = []
out << "-- Seed data extracted from #{SOURCE}"
out << "-- Load after migrations: rake db:seed"
out << ""
out << "BEGIN;"
out << ""
out << "TRUNCATE aliases, tods, characters, settings, timers RESTART IDENTITY CASCADE;"
out << ""

out << "-- timers"
db.execute("SELECT * FROM timers ORDER BY id").each do |row|
  values = [
    row["id"],
    pg_escape(blank_to_nil(row["name"])),
    pg_escape(blank_to_nil(row["window_start"])),
    pg_escape(blank_to_nil(row["window_end"])),
    pg_escape(blank_to_nil(row["variance"])),
    bool_or_null(row["alerted"]),
    num_or_null(row["last_tod"]),
    bool_or_null(row["alerting_soon"].nil? || row["alerting_soon"] == "" ? 0 : row["alerting_soon"]),
    row["skip_count"].nil? || row["skip_count"] == "" ? 0 : row["skip_count"].to_i,
    bool_or_null(row["auto_tod"].nil? || row["auto_tod"] == "" ? 0 : row["auto_tod"]),
    num_or_null(row["linked_timer_id"]),
    num_or_null(row["clear_parent_timer_id"]),
    pg_escape(blank_to_nil(row["warn_time"]))
  ].join(", ")

  out << "INSERT INTO timers (id, name, window_start, window_end, variance, alerted, last_tod, alerting_soon, skip_count, auto_tod, linked_timer_id, clear_parent_timer_id, warn_time) VALUES (#{values});"
end
out << ""

out << "-- settings"
db.execute("SELECT * FROM settings ORDER BY id").each do |row|
  out << "INSERT INTO settings (id, key, value) VALUES (#{row["id"]}, #{pg_escape(row["key"])}, #{pg_escape(row["value"])});"
end
out << ""

out << "-- aliases"
db.execute("SELECT * FROM aliases ORDER BY id").each do |row|
  out << "INSERT INTO aliases (id, timer_id, name, created_at) VALUES (#{row["id"]}, #{row["timer_id"]}, #{pg_escape(row["name"])}, #{pg_escape(row["created_at"])});"
end
out << ""

out << "-- tods"
db.execute("SELECT * FROM tods ORDER BY id").each do |row|
  values = [
    row["id"],
    num_or_null(row["timer_id"]),
    pg_escape(blank_to_nil(row["user_id"])),
    pg_escape(blank_to_nil(row["username"])),
    pg_escape(blank_to_nil(row["display_name"])),
    num_or_null(row["tod"]),
    pg_escape(row["created_at"])
  ].join(", ")

  out << "INSERT INTO tods (id, timer_id, user_id, username, display_name, tod, created_at) VALUES (#{values});"
end
out << ""

out << "-- characters"
db.execute("SELECT * FROM characters ORDER BY id").each do |row|
  values = [
    row["id"],
    pg_escape(row["name"]),
    pg_escape(blank_to_nil(row["inventory_data"])),
    pg_escape(blank_to_nil(row["spellbook_data"])),
    pg_escape(blank_to_nil(row["inventory_updated_at"])),
    pg_escape(blank_to_nil(row["spellbook_updated_at"])),
    pg_escape(blank_to_nil(row["created_at"])),
    pg_escape(blank_to_nil(row["updated_at"]))
  ].join(", ")

  out << "INSERT INTO characters (id, name, inventory_data, spellbook_data, inventory_updated_at, spellbook_updated_at, created_at, updated_at) VALUES (#{values});"
end
out << ""

%w[timers settings aliases tods characters].each do |table|
  out << "SELECT setval(pg_get_serial_sequence('#{table}', 'id'), COALESCE((SELECT MAX(id) FROM #{table}), 1));"
end

out << ""
out << "COMMIT;"
out << ""

FileUtils.mkdir_p(File.dirname(DEST))
File.write(DEST, out.join("\n"))
puts "Wrote #{DEST}"
