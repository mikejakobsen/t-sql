USE Mike;

create table Users(
	Id integer primary key not null identity(1,1),
	Email varchar(255) not null unique
);

create table Role(
	Id integer primary key not null identity(1,1),
	Name varchar(50) not null unique
);

create table UserRole(
	UserId integer references Users(Id) on delete cascade,
	RoleId integer references Role(Id) on delete cascade
	primary key(UserId,RoleId)
);

USE Mike;

Insert into Users(Email)
values('mike@jakobsen.dk');

insert into Role(Name)
values('Admin');

insert into UserRole(UserId,RoleId)
values(1,1);