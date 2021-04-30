Sequel.migration do
  up do
    create_table(:timers) do
      primary_key :id
      String :name
      String :window_start
      String :window_end
      String :variance
      Boolean :alerted
      Decimal :last_tod
    end
  end

  down do
    drop_table(:timers)
  end
end
