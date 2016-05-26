use BigMachine;

Drop table Users;

create table Users(
	id integer primary key identity(1,1),
	Email varchar(25) not null unique,
	MoneySpent decimal(10,2),
	CreatedAt datetime not null default getdate(),
	First varchar(25),
	Last varchar(25),
	bio varchar(max)
);