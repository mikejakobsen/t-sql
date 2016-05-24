USE Blog;
GO

CREATE VIEW dbo.FirstLevelCategories
AS

SELECT
  CategoryId,
  Name
FROM dbo.Categories
WHERE ParentId IS NULL;