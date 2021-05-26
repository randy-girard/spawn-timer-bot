Sequel.migration do
  up do
    create_table(:tods) do
      primary_key :id
      foreign_key :timer_id, :timers
      String :user_id
      String :username
      String :display_name
      Decimal :tod
      DateTime :created_at
    end
  end

  down do
    drop_table(:tods)
  end
end
