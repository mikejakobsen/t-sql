USE Blog;
GO

CREATE PROCEDURE dbo.CreateForeignKeys
AS
BEGIN
  
  ALTER TABLE dbo.Users  
    ADD
      CONSTRAINT FK_Users_Roles_RoleId
        FOREIGN KEY(RoleId)
        REFERENCES dbo.Roles(RoleId);
  
  ALTER TABLE dbo.Posts
    ADD
      CONSTRAINT FK_Posts_Users_UserId
        FOREIGN KEY(UserId)
        REFERENCES dbo.Users(UserId),
      CONSTRAINT FK_Posts_States_StateId
        FOREIGN KEY(StateId)
        REFERENCES dbo.States(StateId);
  
  ALTER TABLE dbo.Categories
    ADD
      CONSTRAINT FK_ParentId_CategoryId
        FOREIGN KEY(ParentId)
        REFERENCES dbo.Categories(CategoryId);
  
  ALTER TABLE dbo.PostsCategories
    ADD
      CONSTRAINT FK_PostsCategories_Posts_PostId
        FOREIGN KEY(PostId)
        REFERENCES dbo.Posts(PostId),
      CONSTRAINT FK_PostsCategories_Categories_CategoryId
        FOREIGN KEY(CategoryId)
        REFERENCES dbo.Categories(CategoryId);
  
  ALTER TABLE dbo.PostsTags
    ADD
      CONSTRAINT FK_PostsTags_Posts_PostId
        FOREIGN KEY(PostId)
        REFERENCES dbo.Posts(PostId),
      CONSTRAINT FK_PostsTags_Tags_TagId
        FOREIGN KEY(TagId)
        REFERENCES dbo.Tags(TagId);

  ALTER TABLE dbo.Comments
    ADD
      CONSTRAINT FK_Comments_Posts_PostId
        FOREIGN KEY(PostId)
        REFERENCES dbo.Posts(PostId),
      CONSTRAINT FK_Comments_Users_UserId
        FOREIGN KEY(UserId)
        REFERENCES dbo.Users(UserId),
      CONSTRAINT FK_Comments_Comments_ParentId
        FOREIGN KEY(ParentId)
        REFERENCES dbo.Comments(CommentId);

END