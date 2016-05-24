USE Blog;

SELECT
  PostId,
  Title,
  Body,
  UserId,
  StateId
FROM dbo.Posts
WHERE StateId = 2 -- Published
ORDER BY PostId DESC
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY;