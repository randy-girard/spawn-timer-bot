Sequel.migration do
  up do
    create_table(:characters) do
      primary_key :id
      String :name, null: false, unique: true
      Text :inventory_data
      Text :spellbook_data
      DateTime :inventory_updated_at
      DateTime :spellbook_updated_at
      DateTime :created_at
      DateTime :updated_at
    end
  end

  down do
    drop_table(:characters)
  end
end
