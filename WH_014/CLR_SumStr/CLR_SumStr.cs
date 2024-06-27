using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;


[Serializable]
[Microsoft.SqlServer.Server.SqlUserDefinedAggregate(Format.UserDefined,/*MaxByteSize = 8000*/MaxByteSize=-1)]
public struct CLR_SumStr: IBinarySerialize
{
    public void Init()
    {
        totalValue = new SqlString("");
    }

    public void Accumulate([SqlFacet(MaxSize = -1)]SqlString Value)
    {
        if (!Value.IsNull)
            totalValue = SqlString.Concat(totalValue.Value,Value.Value);
    }

    public void Merge(CLR_SumStr Group)
    {
        totalValue += Group.totalValue;
    }

    [return: SqlFacet(MaxSize = -1)]
    public SqlString Terminate()
    {
        string value = totalValue.Value;
        if (value.Length > 0)
            value = value.Substring(0,value.Length-1);
        return new SqlString(value);
    }

    [SqlFacet(MaxSize = -1)]
    private SqlString totalValue;


    #region IBinarySerialize Members

    public void Read(System.IO.BinaryReader r)
    {
        totalValue = r.ReadString();
    }

    public void Write(System.IO.BinaryWriter w)
    {
        w.Write(totalValue.Value);
    }

    #endregion
}
