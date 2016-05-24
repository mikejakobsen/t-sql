USE Blog;
GO

CREATE PROCEDURE dbo.GetCommentsForBlogPost
  @PostId AS INT
AS
BEGIN

  SELECT
    C.CommentId,
    C.Body AS Comment,
    C.Created,
    C.Edited,
    C.ParentId,
    U.UserId,
    U.Name
  FROM dbo.Comments AS C
    INNER JOIN dbo.Users AS U
      ON C.UserId = U.UserId
  WHERE C.PostId = @PostId;

END