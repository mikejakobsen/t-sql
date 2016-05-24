USE Blog;

SELECT
  CategoryId,
  Name
FROM dbo.Categories
WHERE ParentId IS NULL;