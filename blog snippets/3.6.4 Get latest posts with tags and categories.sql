USE Blog;
GO

CREATE PROCEDURE dbo.GetLatestPostsWithTagsAndCategories
  @ForDays AS INT = 10
AS
BEGIN

  SELECT
    U.Name AS Author,
    P.Title,
    P.Created,
    P.Edited,
    T.TagId,
    T.Name AS TagName,
    C.CategoryId,
    C.Name AS CategoryName
  FROM dbo.Posts AS P
    INNER JOIN dbo.Users AS U
      ON P.UserId = U.UserId
    LEFT OUTER JOIN dbo.PostsCategories AS PC
      ON P.PostId = PC.PostId
    INNER JOIN dbo.Categories AS C
      ON PC.CategoryId = C.CategoryId
    LEFT OUTER JOIN dbo.PostsTags AS PT
      ON P.PostId = PT.PostId
    INNER JOIN dbo.Tags AS T
      ON PT.TagId = T.TagId
    INNER JOIN dbo.States AS S
      ON P.StateId = S.StateId
  WHERE (S.Name = N'Published' OR S.Name = N'Archived')
    AND P.Created >= DATEADD(DAY, -@ForDays, CAST(GETDATE() AS DATE));

END