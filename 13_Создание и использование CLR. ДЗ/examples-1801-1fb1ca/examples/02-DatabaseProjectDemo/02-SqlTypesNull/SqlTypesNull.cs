using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public class UserDefinedFunctions
{
    [SqlFunction]
    public static int AddNullError(int n1, int n2)
    {
        return n1 + n2;
    }

    [SqlFunction]
    public static int AddNullable(int? n1, int? n2)
    {
        if (n1 == null)
        {
            n1 = 0;
        }

        if (n2 == null)
        {
            n2 = 0;
        }

        return n1.Value + n2.Value;
    }

    [SqlFunction]
    public static SqlInt32 AddNullGood(
        SqlInt32 n1, SqlInt32 n2)
    {
        return n1 + n2;
    }

    [SqlFunction]
    public static SqlInt32 AddNullGoodZero(
        SqlInt32 n1, SqlInt32 n2)
    {
        // ѕроверка n1 == null дл€ SqlInt32 работать не будет
        // null в C# и SQL Server - разные пон€ти€

        if (n1.IsNull)
        {
            n1 = 0;
        }

        if (n2.IsNull)
        {
            n2 = 0;
        }

        return n1 + n2;
    }

    [SqlFunction]
    public static SqlInt32 NullIfZero(SqlInt32 num)
    {
        if (num == 0)
        {
            return SqlInt32.Null;
        }

        return num;
    }


    [SqlFunction]
    public static int? NullBad()
    {
        return null;
    }
}
