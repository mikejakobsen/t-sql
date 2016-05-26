USE BigMachine;

Drop table Users;

create table Users(
	id integer primary key identity(1,1),
	email varchar(50) not null
);
create table Users_Roles(
	UserId integer,
	RoleId integer,
	primary key(UserId,RoleId)
);
create table Roles(
	Id integer primary key identity(1,1),
	Name varchar(50)
);