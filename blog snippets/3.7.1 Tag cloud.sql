USE Blog;
GO

CREATE VIEW dbo.TagCloud
AS

SELECT
  T.TagId,
  T.Name,
  COUNT(*) AS NumberOfPosts
FROM dbo.PostsTags AS PT
  INNER JOIN dbo.Tags AS T
    ON PT.TagId = T.TagId
GROUP BY T.TagId, T.Name;