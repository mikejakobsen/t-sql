USE Blog;

SELECT
  PostId,
  Title,
  Body,
  UserId,
  StateId
FROM dbo.Posts;

SELECT
  PostId,
  CategoryId
FROM dbo.PostsCategories;

SELECT
  PostId,
  TagId
FROM dbo.PostsTags;