USE Blog;
GO

CREATE PROCEDURE dbo.SeedTestData
AS
BEGIN

  INSERT INTO dbo.Roles(Name)
    VALUES
      (N'Administrator'),
      (N'Author'),
      (N'Commentator');
  
  INSERT INTO dbo.States(Name)
     VALUES
      (N'Draft'),
      (N'Published'),
      (N'Archived'),
      (N'Hidden');
  
  INSERT INTO dbo.Tags(Name)
     VALUES
      (N'Story time'),
      (N'Me'),
      (N'Thanks'),
      (N'Must know'),
      (N'Illustrated');
  
  INSERT INTO dbo.Categories(Name)
    VALUES
      (N'Basics'),
      (N'Intermediate'),
      (N'Advanced');
  
  INSERT INTO dbo.Users (Name, Email, [Password], RoleId)
    VALUES
      (N'Jane Doe', 'jane.doe@gmail.com', 'passw0rd', 1),
      (N'John Palmer', 'j.palmer@gmail.com', 'qwerty123', 2),
      (N'Tonny', 'tonny@gmail.com', 'ynnot', 3);
  
  INSERT INTO dbo.Posts (Title, Body, UserId, StateId, Created)
     VALUES
      ( 
        N'Introduction',
		N'<p>There are many good books on homebrewing [...]',
        1,
        2,
        DATEADD(DAY, -11, GETDATE())
      ),
      ( 
        N'Acknowledgments',
		N'<p>There are many good books on homebrewing [...]',
        1,
        2,
        DATEADD(DAY, -10, GETDATE())
      ),
      (
        N'Glossary',
		N'<p>One of the first things a new brewer [...]',
        1,
        2,
        DATEADD(DAY, -5, GETDATE())
      ),
      ( 
        N'Equipment',
		N'<p>An obvious first question most new [...]',
        1,
        1,
        GETDATE()
      );
  
  INSERT INTO dbo.PostsCategories(PostId, CategoryId)
    VALUES
      (1, 1),
      (2, 1),
      (3, 2),
      (4, 3);
  
  INSERT INTO dbo.PostsTags(PostId, TagId)
    VALUES
      (1, 1),
      (1, 2),
      (2, 2),
      (2, 3),
      (3, 4),
      (4, 4),
      (4, 5);
  
  INSERT INTO dbo.[Permissions] (Name)
    VALUES
      (N'Read'),
      (N'Establish'),
      (N'Edit'),
      (N'Delete');
  
  INSERT INTO dbo.RolesPermissions (RoleId, PermissionId)
    VALUES
      -- Administrator
      (1, 1),
      (1, 2),
      (1, 3),
      (1, 4),
      -- Author
      (2, 1),
      (2, 2),
      (2, 3);
  
  INSERT INTO dbo.Categories (Name, ParentId)
    VALUES
      (N'Beginning brewer', 1),
      (N'Thermo-nuclear brewing', 3),
      (N'Home brewing', 4),
      (N'Basement', 6);

  INSERT INTO dbo.Comments (PostId, UserId, Created, Body, ParentId)
    VALUES
      (3, 3, DATEADD(DAY, -4, GETDATE()), N'Pretty cool content! Keep it up!', NULL),
      (3, 2, DATEADD(DAY, -4, GETDATE()), N'Totally agree', 1);

END