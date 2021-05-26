DB = Sequel.connect(DATABASE_URL)

Sequel.extension :migration
Sequel::Migrator.run(DB, 'db/migrate', :use_transactions=>true)
