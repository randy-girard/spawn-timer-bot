Sequel.migration do
  up do
    alter_table(:timers) do
      add_column :skip_count, Integer, default: 0
    end
  end

  down do
    alter_table(:timers) do
      drop_column :skip_count
    end
  end
end
