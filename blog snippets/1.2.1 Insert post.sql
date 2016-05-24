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