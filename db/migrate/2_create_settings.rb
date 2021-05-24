Sequel.migration do
  up do
    create_table(:settings) do
      primary_key :id
      String :key
      String :value
    end
  end

  down do
    drop_table(:settings)
  end
end
