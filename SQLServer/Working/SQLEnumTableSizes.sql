/*************************************************************************************************
**        SQL Server: Identify Large Tables In A Database With Row Count And Size
**        Desc: Reports on physical size of tables in your database to identify largest.
**
**        Return values: result set
** 
**        Called by: 
** 
**        Parameters:
**        Input
**        ----------
**        none
**
**        Output
**        -----------
**        none
**
**        Auth: Jesse mcLain
**        Date: 01/31/2008
**
***************************************************************************************************
**        Change History
***************************************************************************************************
**        Date:        Author:                Description:
**        --------    --------            -------------------------------------------
**        20080131    Jesse McLain        Created script
**        20090213    Jesse McLain        Added 'TRUE' param to call to 'sp_spaceused' - this updates 
**                                        the tableusage to provide more accurate results - thanks to Doug
**                                        (http://www.sqlservercentral.com/Forums/UserInfo437086.aspx).
**                                        Also changed use of Sysobjects to INFORMATION_SCHEMA.TABLES
**************************************************************************************************/
IF EXISTS(SELECT * FROM TempDb.dbo.SysObjects WHERE NAME = '##Space_Used') DROP TABLE ##Space_Used 

CREATE TABLE ##Space_Used (
name nvarchar(128), 
rows char(11), 
reserved varchar(18), 
data varchar(18), 
index_size varchar(18), 
unused varchar(18)
)

DECLARE @User_Table_Schema varchar(max)
DECLARE @User_Table_Name varchar(max)
DECLARE @User_Table_Name_with_Schema varchar(max)

DECLARE User_Tables_Cursor CURSOR FOR
SELECT Table_Schema, Table_Name
FROM INFORMATION_SCHEMA.TABLES
WHERE Table_Type = 'BASE TABLE'

OPEN User_Tables_Cursor 

FETCH NEXT FROM User_Tables_Cursor INTO @User_Table_Schema, @User_Table_Name 
WHILE @@FETCH_STATUS = 0
BEGIN
SET @User_Table_Name_with_Schema = @User_Table_Schema + '.' + @User_Table_Name
PRINT @User_Table_Name_with_Schema 

INSERT INTO ##Space_Used
EXEC sp_spaceused @User_Table_Name_with_Schema, 'TRUE'

 FETCH NEXT FROM User_Tables_Cursor INTO @User_Table_Schema, @User_Table_Name 
END

CLOSE User_Tables_Cursor
DEALLOCATE User_Tables_Cursor

IF EXISTS(SELECT * FROM TempDb.dbo.SysObjects WHERE NAME = '##Space_Used2') DROP TABLE ##Space_Used2

SELECT 
TableName=LEFT(Name, 50),
"RowCount"=Rows,
Phys_Size_KB = CONVERT(int, LEFT(Reserved, PATINDEX('% KB', Reserved) - 1))
FROM ##Space_Used
ORDER BY Phys_Size_KB DESC

IF EXISTS(SELECT * FROM TempDb.dbo.SysObjects WHERE NAME = '##Space_Used') DROP TABLE ##Space_Used 


