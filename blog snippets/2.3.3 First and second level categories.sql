USE Blog;

SELECT
  L1.CategoryId AS L1CategoryId,
  L1.Name AS L1Name,
  L2.CategoryId AS L2CategoryId,
  L2.Name AS L2Name
FROM dbo.Categories AS L1
  LEFT OUTER JOIN dbo.Categories AS L2
    ON L1.CategoryId = L2.ParentId
WHERE L1.ParentId IS NULL;