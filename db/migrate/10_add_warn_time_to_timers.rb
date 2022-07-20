Sequel.migration do
  up do
    alter_table(:timers) do
      add_column :warn_time, String
    end
  end

  down do
    alter_table(:timers) do
      drop_column :warn_time
    end
  end
end
