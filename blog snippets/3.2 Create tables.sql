USE Blog;
GO

CREATE PROCEDURE dbo.CreateTables
AS
BEGIN

  CREATE TABLE dbo.Roles
  (
    RoleId INT NOT NULL IDENTITY,
    Name NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_RoleId
      PRIMARY KEY(RoleId)
  );
  
  CREATE TABLE dbo.Users
  (
    UserId INT NOT NULL IDENTITY,
    Email NVARCHAR(255) NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    [Password] NVARCHAR(64) NOT NULL,
    Created DATETIME NOT NULL DEFAULT GETDATE(),
    RoleId INT NOT NULL,
    CONSTRAINT PK_UserId
      PRIMARY KEY(UserId)
  );
  
  CREATE TABLE dbo.States
  (
    StateId INT NOT NULL IDENTITY,
    Name NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_StateId
      PRIMARY KEY(StateId),
  );
  
  CREATE TABLE dbo.Posts
  (
    PostId INT NOT NULL IDENTITY,
    Title NTEXT NOT NULL,
    Body NTEXT,
    Created DATETIME NOT NULL DEFAULT GETDATE(),
    Edited DATETIME,
    UserId INT NOT NULL,
    StateId INT,
    CONSTRAINT PK_Post
      PRIMARY KEY(PostId)
  );
  
  CREATE TABLE dbo.Categories
  (
    CategoryId INT NOT NULL IDENTITY,
    Name NVARCHAR(255) NOT NULL,
    ParentId INT,
    CONSTRAINT PK_CategoryId
      PRIMARY KEY(CategoryId)
  );
  
  CREATE TABLE dbo.PostsCategories
  (
    PostId INT NOT NULL,
    CategoryId INT NOT NULL,
    CONSTRAINT PK_PostId_CategoryId
      PRIMARY KEY (PostId,CategoryId)
  );
  
  CREATE TABLE dbo.Tags
  (
    TagId INT NOT NULL IDENTITY,
    Name NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_TagId
      PRIMARY KEY(TagId),
  );
  
  CREATE TABLE dbo.PostsTags
  (
    PostId INT NOT NULL,
    TagId INT NOT NULL,
    CONSTRAINT PK_PostId_TagId
      PRIMARY KEY (PostId,TagId)
  );
  
  CREATE TABLE dbo.[Permissions]
  (
    PermissionId INT NOT NULL IDENTITY,
    Name NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_PermissionId
      PRIMARY KEY(PermissionId),
  );
  
  CREATE TABLE dbo.[RolesPermissions]
  (
    RoleId INT NOT NULL,
    PermissionId INT NOT NULL,
    CONSTRAINT PK_RoleId_PermissionId
     PRIMARY KEY (RoleId, PermissionId)
  );

  CREATE TABLE dbo.Comments
  (
    CommentId INT NOT NULL IDENTITY,
    PostId INT NOT NULL,
    UserId INT NOT NULL,
    Created DATETIME NOT NULL DEFAULT GETDATE(),
    Edited DATETIME,
    Body NTEXT,
    ParentId INT,
    CONSTRAINT PK_CommentId
      PRIMARY KEY(CommentId)
  );

END