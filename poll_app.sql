-- Code from TSQL Fundamentals book
-- ensuring that database is dropped before creating one
USE master;

-- Drop database
IF DB_ID('PollApp') IS NOT NULL DROP DATABASE PollApp;

-- If database could not be created due to open connections, abort
IF @@ERROR = 3702 
   RAISERROR('Database cannot be dropped because there are still open connections.', 127, 127) WITH NOWAIT, LOG;

-- Starting assignment
-- SQL assignment 1 (tables)
CREATE DATABASE PollApp;
GO

USE PollApp;
GO

CREATE TABLE dbo.[User]
(
	UserId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Email VARCHAR(255) NOT NULL
);

CREATE TABLE dbo.Question
(
	QuestionId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Question VARCHAR(255) NOT NULL
);

CREATE TABLE dbo.[Option]
(
	OptionId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[Option] VARCHAR(255) NOT NULL,
);

CREATE TABLE dbo.Answer
(
	AnswerId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	OptionId INT
		CONSTRAINT FK_Answer_Option
			FOREIGN KEY(OptionId)
			REFERENCES dbo.[Option](OptionId),
	UserId INT
		CONSTRAINT FK_Answer_User
			FOREIGN KEY(UserId)
			REFERENCES dbo.[User](UserId)
);

CREATE TABLE dbo.OptionQuestion
(
	OptionQuestionId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	OptionId INT NOT NULL
		CONSTRAINT FK_OptionQuestion_Option
			FOREIGN KEY(OptionId)
			REFERENCES dbo.[Option](OptionId),
	QuestionId INT NOT NULL 
		CONSTRAINT FK_OptionQuestion_Question
			FOREIGN KEY(QuestionId)
			REFERENCES dbo.Question(QuestionId)
);

-- Changing the excerise
-- Drop OptionId 
ALTER TABLE dbo.Answer
	DROP 
		CONSTRAINT FK_Answer_Option,
		COLUMN OptionId

-- ...and add OptionQuestionId to be able to find out what question user answered
ALTER TABLE dbo.Answer
	ADD
		OptionQuestionId INT NOT NULL
		CONSTRAINT FK_Answer_OptionQuestion
			FOREIGN KEY(OptionQuestionId)
			REFERENCES dbo.OptionQuestion(OptionQuestionId);

-- End of SQL assignment 1 (tables)

-- SQL assignment 2 (INSERT)
INSERT INTO dbo.[User] (Email)
	VALUES 
		('mike@foobar.com'),
		('bob@foobar.com'),
		('john@foobar.com'),
		('bill@foobar.com'),
		('jane@foobar.com');

SELECT UserId, Email
FROM dbo.[User];

INSERT INTO dbo.[Option] ([Option])
	VALUES
		('Red'),
		('Green'),
		('Blue'),
		('Other');

SELECT OptionId, [Option]
FROM dbo.[Option];

INSERT INTO dbo.Question (Question)
	VALUES
		('What is your favourite color?'),
		('What is your least favourite color?');

SELECT QuestionId, Question
FROM Question;

INSERT INTO dbo.OptionQuestion (QuestionId, OptionId)
	VALUES
		(1, 1),
		(1, 2),
		(1, 3),
		(1, 4),
		(2, 1),
		(2, 2),
		(2, 3),
		(2, 4);

SELECT OptionQuestionId, QuestionId, OptionId
FROM dbo.OptionQuestion;

INSERT INTO dbo.Answer (UserId, OptionQuestionId)
	VALUES
		(1, 1),
		(2, 2),
		(3, 2),
		(4, 4),
		(1, 5),
		(2, 6),
		(3, 8),
		(4, 8),
		(5, 1),
		(5, 8);

SELECT AnswerId, UserId, OptionQuestionId
FROM dbo.Answer;
-- End of SQL assignment 2 (INSERT)

-- SQL assignment 3 (SELECT, JOIN, COUNT, GROUP BY)
-- 1.
SELECT dbo.Question.Question, dbo.[Option].[Option]
FROM dbo.OptionQuestion
INNER JOIN dbo.[Option] ON dbo.OptionQuestion.OptionId = dbo.[Option].OptionId
INNER JOIN dbo.Question ON dbo.OptionQuestion.QuestionId = dbo.Question.QuestionId;

-- 2.
SELECT
	COUNT(*) AS CountOptions
FROM dbo.Answer
INNER JOIN dbo.OptionQuestion ON dbo.Answer.OptionQuestionId = dbo.OptionQuestion.OptionQuestionId
INNER JOIN dbo.[Option] ON dbo.OptionQuestion.OptionId = dbo.[Option].OptionId
WHERE dbo.[Option].[Option] = 'Red';

-- 3.
-- Joint tables view
/*
SELECT *
FROM dbo.Answer
INNER JOIN dbo.OptionQuestion ON dbo.Answer.OptionQuestionId = dbo.OptionQuestion.OptionQuestionId
INNER JOIN dbo.[Option] ON dbo.OptionQuestion.OptionId = dbo.[Option].OptionId
INNER JOIN dbo.[Question] ON dbo.OptionQuestion.QuestionId = dbo.Question.QuestionId;
*/

-- Answer
SELECT
	dbo.[Question].Question,
	dbo.[Option].[Option],
	COUNT(*) AS CountOption
FROM dbo.Answer
INNER JOIN dbo.OptionQuestion ON dbo.Answer.OptionQuestionId = dbo.OptionQuestion.OptionQuestionId
INNER JOIN dbo.[Option] ON dbo.OptionQuestion.OptionId = dbo.[Option].OptionId
INNER JOIN dbo.[Question] ON dbo.OptionQuestion.QuestionId = dbo.Question.QuestionId
GROUP BY dbo.Question.Question, dbo.[Option].[Option]
ORDER BY dbo.Question.Question, dbo.[Option].[Option];

-- 4.
-- Joint tables view helper
/*
SELECT *
FROM dbo.Answer
RIGHT OUTER JOIN dbo.OptionQuestion ON dbo.Answer.OptionQuestionId = dbo.OptionQuestion.OptionQuestionId
INNER JOIN dbo.[Option] ON dbo.OptionQuestion.OptionId = dbo.[Option].OptionId
INNER JOIN dbo.[Question] ON dbo.OptionQuestion.QuestionId = dbo.Question.QuestionId;
*/

-- Answer
SELECT
	dbo.[Question].Question,
	dbo.[Option].[Option],
	COUNT(dbo.Answer.OptionQuestionId) AS CountOption
FROM dbo.Answer
RIGHT OUTER JOIN dbo.OptionQuestion ON dbo.Answer.OptionQuestionId = dbo.OptionQuestion.OptionQuestionId
INNER JOIN dbo.[Option] ON dbo.OptionQuestion.OptionId = dbo.[Option].OptionId
INNER JOIN dbo.[Question] ON dbo.OptionQuestion.QuestionId = dbo.Question.QuestionId
GROUP BY dbo.Question.Question, dbo.[Option].[Option]
ORDER BY dbo.Question.Question, CountOption DESC;
-- End of SQL assignment 3 (SELECT, JOIN, COUNT, GROUP BY)

-- SQL assignment 4 Extra! (subselect)
-- Joint tables view helper
/*
SELECT *,
	COUNT(dbo.Answer.OptionQuestionId) OVER(PARTITION BY dbo.Question.Question) AS TotalCount
FROM dbo.Answer
RIGHT OUTER JOIN dbo.OptionQuestion ON dbo.Answer.OptionQuestionId = dbo.OptionQuestion.OptionQuestionId
INNER JOIN dbo.[Option] ON dbo.OptionQuestion.OptionId = dbo.[Option].OptionId
INNER JOIN dbo.[Question] ON dbo.OptionQuestion.QuestionId = dbo.Question.QuestionId;
*/

-- Answer
SELECT
	SubSelect.Question,
	SubSelect.[Option],
	COUNT(SubSelect.OptionQuestionId) AS CountOption,
	CAST(ROUND(CAST(COUNT(SubSelect.OptionQuestionId) AS NUMERIC(12, 2)) / TotalCount * 100, 0) AS INT) AS Pct
FROM
	(
		SELECT
			dbo.Question.Question AS Question,
			dbo.[Option].[Option] AS [Option],
			dbo.Answer.OptionQuestionId AS OptionQuestionId,
			COUNT(dbo.Answer.OptionQuestionId) OVER(PARTITION BY dbo.Question.Question) AS TotalCount
		FROM dbo.Answer
		RIGHT OUTER JOIN dbo.OptionQuestion ON dbo.Answer.OptionQuestionId = dbo.OptionQuestion.OptionQuestionId
		INNER JOIN dbo.[Option] ON dbo.OptionQuestion.OptionId = dbo.[Option].OptionId
		INNER JOIN dbo.[Question] ON dbo.OptionQuestion.QuestionId = dbo.Question.QuestionId
	) SubSelect
GROUP BY SubSelect.TotalCount, SubSelect.Question, [Option]
ORDER BY SubSelect.Question, CountOption DESC;
-- End of SQL assignment 4 Extra! (subselect)