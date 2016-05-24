USE Blog;
GO

CREATE PROCEDURE dbo.GetPostTags
  @PostId AS INT
AS
BEGIN

  SELECT 
    T.TagId,
    T.Name
  FROM dbo.PostsTags AS PT
    INNER JOIN dbo.Tags AS T 
      ON PT.TagId = T.TagId
  WHERE PT.PostId = @PostId;

END