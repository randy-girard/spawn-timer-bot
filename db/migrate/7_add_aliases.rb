Sequel.migration do
  up do
    create_table(:aliases) do
      primary_key :id
      foreign_key :timer_id, :timers
      String :name
      DateTime :created_at
    end
  end

  down do
    drop_table(:aliases)
  end
end
