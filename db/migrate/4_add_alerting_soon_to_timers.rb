Sequel.migration do
  up do
    alter_table(:timers) do
      add_column :alerting_soon, TrueClass, default: false
    end
  end

  down do
    alter_table(:timers) do
      drop_column :alerting_soon
    end
  end
end
