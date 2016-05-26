USE BigMachine;

DROP TABLE dbo.Users;

CREATE TABLE Users(
	Id integer primary key identity(1,1),
	email varchar(50)
);