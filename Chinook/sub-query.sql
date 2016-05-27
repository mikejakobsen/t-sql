Use Chinook;

select FirstName, LastName,
	(Select FirstName + ' '+LastName
		from Employee bosses
		where Employee.ReportsTo = bosses.EmployeeId) as Boss
from Employee;

Use Chinook;

Select workers.FirstName + ' '+ workers.LastName As Employee,
bosses.FirstName + ' ' + bosses.LastName as Boss
From Employee workers
Left Join Employee as Bosses
On workers.ReportsTo = Bosses.EmployeeId

Use Chinook;

Select FirstName, LastName,
	(Select FirstName + ' ' + LastName 
		From Employee as Chefer
		Where Employee.ReportsTo = Chefer.EmployeeId) as Chef
from Employee;