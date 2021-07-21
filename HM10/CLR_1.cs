using Microsoft.SqlServer.Server;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlTypes;

namespace CLR_2021
{
    public class CLR_1
    {
        public static bool IsPrimeNumber(SqlInt32 n)
        {
            var result = true;

            if (n > 1)
            {
                for (var i = 2; i < n; i++)
                {
                    if (n % i == 0)
                    {
                        result = false;
                        break;
                    }
                }
            }
            else
            {
                result = false;
            }

            return result;
        }

        public static SqlInt32 NextPrimeNumber(SqlInt32 num)
        {
            var result = 0;
            
            if (num.IsNull)
            {
                result = 0;
            }

            else
            {
                if (num < 2)
                {
                    num = 2;
                }

                if (!IsPrimeNumber(num))
                {
                    for (var i = num.Value + 1; i < 2 * num.Value; i = i + 1)
                    {
                        if (IsPrimeNumber(i))
                        {
                            result = i;
                            break;
                        }
                    }
                }
                else
                {
                    result = num.Value;
                }
            }
            return result;
        }
    }
}
