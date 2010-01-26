# Module extension for defining prequisite tasks.

module Taskable

  # Define or call a task.

  def task n, &block
    case n
    when Hash
      name, preq = *n.to_a[0]
    else
      name, preq = n, []
    end

    task_name = "#{name}:task"

    define_method(task_name) do |cache,*args|
      cache ||= {}
      return cache[name] if cache.key?(name)
      preq.each do |q|
        send("#{q}:task",cache,*args)
      end
      cache[name] = block.call(*args)
    end

    private task_name
  end

  def call_target(name,*a)
    send("#{name}:task",nil,*a)
  end

  #def cache
  #  @taskable_cache ||= {}
  #end

  #def function s, &b
  #  define_method s, &b
  #  private s
  #end

end
