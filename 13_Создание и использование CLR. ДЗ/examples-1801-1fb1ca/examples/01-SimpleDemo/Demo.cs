using Microsoft.SqlServer.Server;
using System.Data;
using System.Data.SqlTypes;

namespace ExampleNamespace
{
    // CLR-���������, ������� ������ ���� ���������� ������������ ��������

    public class DemoClass
    {
        // CLR-������� � ��������� �������� 
        // � ���� ������������ ���������� ������.

        /// <summary>
        /// ������� ����������� ��� ����������� �����.
        /// </summary>
        public static string SayHelloFunction(string name)
        {
            return "Hello, " + name;
        }

        /// <summary>
        /// ������� ����������� ��� ����������� �����.
        /// </summary>
        public static void SayHelloProcedure(SqlString name)
        {
            var pipe = SqlContext.Pipe;

            var columns = new SqlMetaData[1];
            columns[0] = new SqlMetaData("HelloColumn", SqlDbType.NVarChar, 100);

            var row = new SqlDataRecord(columns);
            pipe.SendResultsStart(row);
            for (int i = 0; i < 5; i++)
            {
                row.SetSqlString(0, string.Format("{0} Hello, {1}", i, name));
                pipe.SendResultsRow(row);
            }

            pipe.SendResultsEnd();
        }
    }
}