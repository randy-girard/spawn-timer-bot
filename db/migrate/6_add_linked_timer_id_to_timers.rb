Sequel.migration do
  up do
    alter_table(:timers) do
      add_column :linked_timer_id, Integer
    end
  end

  down do
    alter_table(:timers) do
      drop_column :linked_timer_id
    end
  end
end
