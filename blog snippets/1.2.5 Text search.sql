USE Blog;

SELECT
  PostId,
  Title,
  Body,
  UserId,
  StateId
FROM dbo.Posts
WHERE Title LIKE N'%Equipment%' AND Body LIKE N'%Airlock%';