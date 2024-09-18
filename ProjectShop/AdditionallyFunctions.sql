

/* -- Разбивает- строку на подстроки разделенные указанным разделителем разделителем

Create FUNCTION [dbo].[udf_splitstring] (@string nvarchar(4000), @delimiter nchar(1),@num int)  
RETURNS nvarchar(4000) AS  
BEGIN 
declare @count int, @position int, @oldposition int, @c int

    set @count = 1
    set @position = 0 
    while charindex(@delimiter,@string,@position) > 0 
    begin
    set @position = charindex(@delimiter,@string,@position)+1
    set @count = @count +1
    end

if @num = 0 
begin
    return cast(@count as nvarchar(4000))
end

if @num > 0 and @num <= @count 
begin
    set @c = 1
    set @position = 1
    if @num = @c return substring(@string,0,charindex(@delimiter,@string))
    while charindex(@delimiter,@string,@position) > 0 
    begin
    set @oldposition = @position
    set @position = charindex(@delimiter,@string,@position)+1
    set @c = @c +1
    if @num = @c and @c = @count return substring(@string,charindex(@delimiter,@string,@oldposition)+1,len(@string)-charindex(@delimiter,@string,@oldposition))
    if @num = @c return substring(@string,charindex(@delimiter,@string,@oldposition)+1,charindex(@delimiter,@string,@position)-charindex(@delimiter,@string,@oldposition)-1)
     end      
end
return '---error---'
END
*/
/* -- Функция для разделения строки по указанному символу в таблицу


ALTER FUNCTION [dbo].[udf_splistringtable] (@array NVARCHAR(MAX),@separator NCHAR(1)) 
RETURNS @StrTable TABLE (StringValue Nvarchar(mAX))
AS
BEGIN
    DECLARE @separator_position INT 
    DECLARE @array_value NVARCHAR(MAX)
    SET @array = @array + @separator
    SELECT @separator_position =  PATINDEX('%'+@separator+'%' , @array)
    WHILE @separator_position <> 0
    BEGIN
        SELECT @array_value = LEFT(@array, @separator_position - 1)
        INSERT INTO @StrTable VALUES (@array_value)
        SELECT @array = STUFF(@array, 1, @separator_position, '')
        SELECT @separator_position =  PATINDEX('%'+@separator+'%' , @array)
    END
    RETURN
END


*/