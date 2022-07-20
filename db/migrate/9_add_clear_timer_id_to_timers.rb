Sequel.migration do
  up do
    alter_table(:timers) do
      add_column :clear_parent_timer_id, Integer
    end
  end

  down do
    alter_table(:timers) do
      drop_column :clear_parent_timer_id
    end
  end
end
