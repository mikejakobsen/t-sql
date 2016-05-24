USE Blog;
GO

CREATE PROCEDURE dbo.GetRecentComments
  @Limit AS INT = 10
AS
BEGIN

  SELECT 
    C.CommentId,
    P.PostId,
    P.Title AS PostTitle,
    U.UserId,
    U.Name AS UserName
  FROM dbo.Comments AS C
    INNER JOIN dbo.Posts AS P
      ON C.PostId = P.PostId
    INNER JOIN dbo.Users AS U
      ON C.UserId = U.UserId
  ORDER BY C.Created DESC
  OFFSET 0 ROWS FETCH FIRST @Limit ROWS ONLY;

END