namespace :db do
  desc "Load db/seeds/development.sql into the current DATABASE_URL (Postgres)"
  task seed: :environment do
    seed_path = File.expand_path("../db/seeds/development.sql", __dir__)
    abort "Seed file not found: #{seed_path}" unless File.exist?(seed_path)

    unless DATABASE_URL.to_s.start_with?("postgres")
      abort "db:seed expects a Postgres DATABASE_URL (got #{DATABASE_URL.inspect})"
    end

    sql = File.read(seed_path)
    DB.synchronize do |conn|
      conn.exec(sql)
    end
    puts "Loaded seed data from #{seed_path}"
  end

  desc "Import a pg_dump custom-format file into the DKP database (DKP_DATABASE_URL)"
  task :import_dkp, [:dump_path] => :environment do |_t, args|
    require "uri"

    dump_path = File.expand_path(args[:dump_path] || "#{Dir.home}/Downloads/alfred-bot-db.sql.gz")
    abort "Dump file not found: #{dump_path}" unless File.exist?(dump_path)
    abort "DKP_DATABASE_URL is not set" if DKP_DATABASE_URL.to_s.strip.empty?

    uri = URI.parse(DKP_DATABASE_URL)
    env = { "PGPASSWORD" => uri.password.to_s }
    cmd = [
      "pg_restore",
      "--clean",
      "--if-exists",
      "--no-owner",
      "--no-acl",
      "-h", uri.host || "localhost",
      "-p", (uri.port || 5432).to_s,
      "-U", uri.user || "spawn_timer",
      "-d", uri.path.to_s.delete_prefix("/"),
      dump_path
    ]

    puts "Importing #{dump_path} into #{uri.path.to_s.delete_prefix('/')}..."
    ok = system(env, *cmd)
    # pg_restore can exit non-zero on ignorable warnings; verify by querying
    count = DKP_DB[:characters].count
    puts "Imported DKP data (#{count} characters)."
    abort "pg_restore failed" unless ok || count > 0
  end
end
