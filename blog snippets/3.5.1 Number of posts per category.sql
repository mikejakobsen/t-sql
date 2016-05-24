USE Blog;
GO

CREATE VIEW dbo.NumberOfPostsPerCategory
AS

SELECT
  C.CategoryId,
  C.Name,
  COUNT(*) AS PostsInCategory
FROM dbo.PostsCategories AS PC
  INNER JOIN dbo.Categories C
    ON PC.CategoryId = C.CategoryId
GROUP BY C.CategoryId, C.Name;