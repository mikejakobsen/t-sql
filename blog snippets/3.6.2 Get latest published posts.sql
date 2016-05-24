USE Blog;
GO

CREATE PROCEDURE dbo.GetLatestPublishedPosts
  @Limit AS INT = 10
AS
BEGIN

  SELECT
    PostId,
    Title,
    Body,
    UserId,
    StateId
  FROM dbo.Posts
  WHERE StateId = 2 -- Published
  ORDER BY PostId DESC
  OFFSET 0 ROWS FETCH FIRST @Limit ROWS ONLY;

END