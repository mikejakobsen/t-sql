USE Blog;
GO

CREATE VIEW dbo.UsersPermissionsRoles
AS

SELECT
  U.UserId,
  U.Name,
  U.Email,
  R.Name AS [Role],
  P.Name AS Permission
FROM Users AS U
  INNER JOIN Roles AS R
    ON U.RoleId = R.RoleId
  LEFT OUTER JOIN RolesPermissions AS RP
    ON R.RoleId = RP.RoleId
  LEFT OUTER JOIN [Permissions] AS P
    ON RP.PermissionId = P.PermissionId;