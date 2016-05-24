USE Blog;
GO

CREATE TRIGGER TriggerPostAudit
  ON dbo.Posts
  AFTER INSERT, UPDATE, DELETE
AS
BEGIN

  SET NOCOUNT ON;

  --
  -- Check if this is an INSERT, UPDATE or DELETE Action.
  -- 
  DECLARE @action AS CHAR(1);
  
  SET @action = 'I'; -- Set Action to Insert by default.
  IF EXISTS(SELECT * FROM DELETED)
  BEGIN
      
      SET @action = 
          CASE
              WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' -- Set Action to Updated.
              ELSE 'D' -- Set Action to Deleted.       
          END
  END
  ELSE 
      IF NOT EXISTS(SELECT * FROM INSERTED) RETURN; -- Nothing updated or inserted.
  
  -- Create a log record
  IF @action = 'I' OR @action = 'U'
  BEGIN
    INSERT INTO dbo.PostLog ([Action], PostId, PostTitle)
    SELECT @action AS [Action], PostId, Title FROM INSERTED;
  END

  ELSE
  BEGIN
    INSERT INTO dbo.PostLog ([Action], PostId, PostTitle)
    SELECT @action AS [Action], PostId, Title FROM DELETED;
  END

END