------------------------------------------------------------------------------------------------------------------------
-- TASK_3_EXCEPTIONS | ��������� ����������
------------------------------------------------------------------------------------------------------------------------
��� ������� � ���� ����?
```
public IQueryable<T> GetAll()
{
	try
	{
		return dbSet.AsQueryable();
	}
	catch (Exception ex)
	{
		throw new Exception(ex.Message);
	}
}
```

��������� �� ����:
1. �������� `ex.InnerException`.
2. ��������� �����������. ����� ������� ��� ��������� `Message`, ���� ������������� ���� ������ `ex` � XML. ����� ����� �������� ������, �� ����� ������ ����� �������.
3. ��������� Exception ���������� �������� � ����������� ����������� ������������.
4. �� ��������, ����� �������� �������� � �����, ���������� � ���: 
`public IQueryable<T> GetAll([CallerFilePath] string filePath = "", [CallerLineNumber] int lineNumber = 0, [CallerMemberName] string memberName = "")`
