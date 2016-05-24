USE Blog;
GO

CREATE PROCEDURE dbo.SearchPostsByPartialStringInTitleAndBody
  @PartialTitle AS NVARCHAR(255),
  @PartialBody AS NVARCHAR(255)
AS
BEGIN

  SELECT
    PostId,
    Title,
    Body,
    Created,
    Edited,
    UserId,
    StateId
  FROM dbo.Posts
  WHERE Title LIKE N'%' + @PartialTitle + '%' 
    AND Body LIKE N'%' + @PartialBody +'%';

END