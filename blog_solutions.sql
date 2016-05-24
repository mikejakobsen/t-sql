-- 1.2.1
-- Select
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


-- Insert
USE Blog;

INSERT INTO dbo.Posts (Title, Body, UserId, StateId)
VALUES
( 
	N'Brand new blog post',
	N'<p>Brand new content</p>',
	1,
	1 -- Draft
);

INSERT INTO dbo.PostsCategories(PostId, CategoryId)
	VALUES
		(5, 1);
  
INSERT INTO dbo.PostsTags(PostId, TagId)
    VALUES
		(5, 1),
		(5, 2);

-- 1.2.2
USE Blog;

SELECT
	T.TagId,
	T.Name
FROM dbo.PostsTags AS PT
  INNER JOIN dbo.Tags AS T
  ON PT.TagId = T.TagId
WHERE PT.PostId = 5;

-- 1.2.3
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

-- 1.2.4
USE Blog;

SELECT
	C.CategoryId,
	C.Name,
	COUNT(*) AS PostsInCategory
FROM dbo.PostsCategories AS PC
	INNER JOIN dbo.Categories C
	ON PC.CategoryId = C.CategoryId
GROUP BY C.CategoryId, C.Name;