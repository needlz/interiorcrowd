Fabricator(:designer_activity) do

  start_date { DateTime.now }
  due_date { DateTime.now + 3.days }
  task { 'task' }
  hours 4

end
