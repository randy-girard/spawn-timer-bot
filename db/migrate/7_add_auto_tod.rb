Sequel.migration do
  up do
    alter_table(:timers) do
      add_column :auto_tod, TrueClass, default: false
    end
  end

  down do
    alter_table(:timers) do
      drop_column :auto_tod
    end
  end
end
