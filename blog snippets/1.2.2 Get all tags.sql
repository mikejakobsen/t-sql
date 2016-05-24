USE BLOG;

SELECT
  T.TagId,
  T.Name
FROM dbo.PostsTags AS PT
  INNER JOIN dbo.Tags AS T
    ON PT.TagId = T.TagId
WHERE PT.PostId = 5;