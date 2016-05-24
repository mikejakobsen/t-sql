USE Blog;
GO

CREATE PROCEDURE dbo.EstablishDB
AS
BEGIN

  BEGIN TRAN;

    EXECUTE dbo.CreateTables;
    EXECUTE dbo.CreateForeignKeys;

  COMMIT TRAN;

END