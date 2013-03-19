class Employee
	attr_accessor :name, :title, :salary, :boss

	def initialize(name, title, salary, boss = nil)
		@name = name
		@title = title
		@salary = salary
		@boss = boss
	end

	def caclculate_bonus(multi)
		@salary * multi
	end

	def total_salary
		@salary
	end


end

class Manager < Employee
	attr_accessor :employees

	def initialize(name, title, salary, boss = nil, employees = [])
		super(name, title, salary, boss)
		@employees = employees
		set_manager
	end

	def new_employee(employee)
		@employees << employee
		employee.boss = self
	end

	def set_manager
		@employees.each do |emp|
			emp.boss = self
		end
	end

	def calculate_bonus(multi)
		total_salary * multi
	end

	def total_salary
		base_sal = @salary
		unless @employees.empty?
			summed_emp_sals = 0
			@employees.each do |emp|
				summed_emp_sals += emp.total_salary
			end
			base_sal = @salary + summed_emp_sals
		end

		base_sal
	end
end


# def test
# manager = Manager.new("Brian", "Boss", 5)
# employee1 = Manager.new("Ned", "Subserviant", 2)
# employee2 = Employee.new("Kush", "Friend", 4)
# manager.new_employee(employee1)
# employee1.new_employee(employee2)
# puts manager.calculate_bonus(2)
# end


