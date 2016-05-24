USE Blog;
GO

CREATE PROCEDURE dbo.DeletePost
  @PostId AS INT
AS
BEGIN

  BEGIN TRAN;
    
    DELETE FROM dbo.PostsCategories
    WHERE PostId = @PostId;

    DELETE FROM dbo.PostsTags
    WHERE PostId = @PostId;

    DELETE FROM dbo.Comments
    WHERE PostId = @PostId;

    DELETE FROM dbo.Posts
    WHERE PostId = @PostId;

  COMMIT TRAN;

END