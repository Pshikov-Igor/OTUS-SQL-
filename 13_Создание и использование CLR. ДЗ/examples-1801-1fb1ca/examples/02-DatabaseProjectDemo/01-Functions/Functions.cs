using System.Collections;
using System.Collections.Generic;
using System.Data.SqlClient;
using Microsoft.SqlServer.Server;

// ��������� �����
public class ScalarFunctions
{
    // ������� � public static - �������
    
    // ������� - SqlFunctionAttribute:
    // Name - ��� ������� � SQL Server
    // IsDeterministic - ����������������� ������� ��� ���.
    //
    // ����������������� ������� ������ ��� ���������� ���� � ��� �� ���������, 
    // ���� ������������� �� ���� � ��� �� ����� ������� �������� � ������������ ���� � �� �� ��������� ���� ������.
    // ������������������� ������� ����� ���������� ������ ��� ������ ����������.
    // 
    // ������ �� ��, ��� ����� ������������ ������� (��������������� �������������, persisted-�������� � ��).
    // ��������, AVG - �����������������, GETDATE - �������������������.
    // https://docs.microsoft.com/ru-ru/sql/relational-databases/user-defined-functions/deterministic-and-nondeterministic-functions

    // ��������� �������
    [SqlFunction(
        Name = "SumDeterministic",
        IsDeterministic = true)]
    public static int Add(int a1, int a2)
    {
        return a1 + a2;
    }

    // ��������� �������
    [SqlFunction(IsDeterministic = false)]
    public static int SumNondeterministic(int a1, int a2)
    {
        return a1 + a2;
    }

    // ������ ��������� � ������ �� ������ �������
    [SqlFunction(DataAccess = DataAccessKind.Read)]
    public static int CountOrdersForCustomer(int customerID)
    {
        // ������� ADO.NET, �� connection string - "context connection=true"

        using (SqlConnection connection = new SqlConnection("context connection=true"))
        using (SqlCommand cmd = new SqlCommand(
            "SELECT count(*) FROM Sales.Orders WHERE CustomerID = @customerID;", connection))
        {
            cmd.Parameters.AddWithValue("customerID", customerID);
            connection.Open();
            var count = (int)cmd.ExecuteScalar();
            return count;
        }
    }

    // -----------------------------------------
    // ��������� �������
    // Split -> MakeRow
    // -----------------------------------------    
    [SqlFunction(
        TableDefinition = "item nvarchar(100), num int",
        FillRowMethodName = "MakeRow")]
    public static IEnumerable Split(
        string str, 
        string separator)
    {
        var items = str.Split(separator.ToCharArray());

        // � result ����� �������� �������� (��� "�������")
        // object[] - ���� ������
        // ����� ������� � �� ������� - ������ �������, ��������� ������ � ��.
        var result = new List<object[]>();

        for (int i = 0; i < items.Length; i++)
        {
            var row = new object[2];
            row[0] = items[i];
            row[1] = i + 1;
            result.Add(row);
        }

        return result;
    }

    public static void MakeRow(
        object obj, out string item, out int num)
    {
        var row = obj as object[];
        item = (string)row[0];
        num = (int)row[1];
    }
}
