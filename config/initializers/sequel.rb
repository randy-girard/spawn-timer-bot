DB = Sequel.connect(DATABASE_URL)

Sequel.extension :migration
Sequel::Migrator.run(DB, 'db/migrate', :use_transactions=>true)

DB.logger = Logger.new($stdout)

if DKP_DATABASE_URL.to_s.strip != ""
  DKP_DB = Sequel.connect(DKP_DATABASE_URL)
  DKP_DB.logger = Logger.new($stdout)
else
  DKP_DB = nil
end
