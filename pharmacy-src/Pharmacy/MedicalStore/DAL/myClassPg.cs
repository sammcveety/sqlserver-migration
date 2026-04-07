using System;
using System.Data;
using Npgsql;

namespace MedicalStore.DAL
{
    public class myClassPg
    {
        private static readonly string connString =
            System.Configuration.ConfigurationManager.ConnectionStrings["pgCon1"].ConnectionString;

        private DataTable ExecuteQuery(string sql)
        {
            using (NpgsqlConnection conn = new NpgsqlConnection(connString))
            {
                conn.Open();
                DataTable result = new DataTable();
                try
                {
                    NpgsqlDataAdapter adapter = new NpgsqlDataAdapter(sql, conn);
                    adapter.Fill(result);
                }
                catch (NpgsqlException ex)
                {
                    Console.WriteLine("PG Error: " + ex.Message);
                    return null;
                }
                return result;
            }
        }

        private DataTable ExecuteQueryParam(string sql, NpgsqlParameter[] parameters)
        {
            using (NpgsqlConnection conn = new NpgsqlConnection(connString))
            {
                conn.Open();
                DataTable result = new DataTable();
                try
                {
                    NpgsqlCommand cmd = new NpgsqlCommand(sql, conn);
                    foreach (var p in parameters)
                        cmd.Parameters.Add(p);
                    NpgsqlDataAdapter adapter = new NpgsqlDataAdapter(cmd);
                    adapter.Fill(result);
                }
                catch (NpgsqlException ex)
                {
                    Console.WriteLine("PG Error: " + ex.Message);
                    return null;
                }
                return result;
            }
        }

        public DataTable showalldealers()
        {
            return ExecuteQuery("SELECT * FROM Dealer");
        }

        public DataTable showallcompanies()
        {
            return ExecuteQuery("SELECT * FROM Company");
        }

        public DataTable showallsales()
        {
            return ExecuteQuery("SELECT * FROM Sales");
        }

        public DataTable showallpurchases()
        {
            return ExecuteQuery("SELECT * FROM Purchase");
        }

        public DataTable showallEmployees()
        {
            return ExecuteQuery("SELECT * FROM Employ");
        }

        public DataTable findemploy(string id)
        {
            return ExecuteQuery(String.Format("SELECT * FROM Find_Employ('{0}')", id));
        }

        public DataTable searchdealerbyid(string id)
        {
            return ExecuteQuery(String.Format("SELECT * FROM Find_Dealer('{0}')", id));
        }

        public DataTable DealernamefromCompID(string id)
        {
            return ExecuteQuery(String.Format("SELECT * FROM DealernamefromCompID('{0}')", id));
        }

        public DataTable findemployname(string id)
        {
            return ExecuteQuery(String.Format("SELECT * FROM Find_Employ_Name('{0}')", id));
        }

        public DataTable showallMedicine()
        {
            return ExecuteQuery("SELECT * FROM Show_All_Medicine()");
        }

        public DataTable showOutOfStock()
        {
            return ExecuteQuery("SELECT * FROM Show_outofstock()");
        }

        public DataTable showAllExpired()
        {
            return ExecuteQuery("SELECT * FROM Show_All_Expired()");
        }

        public DataTable searchMedicinebyId(string id)
        {
            return ExecuteQuery(String.Format("SELECT * FROM Find_Price('{0}')", id));
        }

        public DataTable ExpireMedicinebyId(string id)
        {
            return ExecuteQuery(String.Format("SELECT * FROM Find_Expiry('{0}')", id));
        }

        public DataTable whotookthesemedicine(string id)
        {
            return ExecuteQuery(String.Format("SELECT * FROM Who_took_these('{0}')", id));
        }

        public DataTable findallinfo(string id)
        {
            return ExecuteQuery(String.Format("SELECT * FROM Find_All_Info('{0}')", id));
        }

        public DataTable quantityleft(string id)
        {
            return ExecuteQuery(String.Format("SELECT * FROM Quantityleft('{0}')", id));
        }

        public DataTable purchasedate(string id)
        {
            return ExecuteQuery(String.Format("SELECT * FROM PurchaseDates('{0}')", id));
        }

        public DataTable noofsale(string id)
        {
            return ExecuteQuery(String.Format("SELECT * FROM noOfSale('{0}')", id));
        }

        public DataTable updatemanf(string id, string id2)
        {
            return ExecuteQuery(String.Format("SELECT * FROM Update_Manf('{0}', '{1}')", id, id2));
        }

        public DataTable updateexpiry(string id, string id2)
        {
            return ExecuteQuery(String.Format("SELECT * FROM Update_Expiry('{0}', '{1}')", id, id2));
        }

        public int Login(string id, string pas)
        {
            using (NpgsqlConnection conn = new NpgsqlConnection(connString))
            {
                conn.Open();
                try
                {
                    NpgsqlCommand cmd = new NpgsqlCommand("SELECT * FROM LoginDatabase(@usr, @pas)", conn);
                    cmd.Parameters.AddWithValue("@usr", id);
                    cmd.Parameters.AddWithValue("@pas", pas);
                    object result = cmd.ExecuteScalar();
                    return Convert.ToInt32(result);
                }
                catch (NpgsqlException ex)
                {
                    Console.WriteLine("PG Error: " + ex.Message);
                    return -5;
                }
            }
        }

        public int Signup(string Name, string Contact, string House, string Designation, int Salary, string Email, string UserN, string Pass)
        {
            using (NpgsqlConnection conn = new NpgsqlConnection(connString))
            {
                conn.Open();
                try
                {
                    // Get last ID
                    NpgsqlCommand cmd1 = new NpgsqlCommand("SELECT * FROM GetLastID()", conn);
                    object lastIdObj = cmd1.ExecuteScalar();
                    int ans = Convert.ToInt32(lastIdObj);
                    if (ans > 1) ans = ans + 1;

                    // Signup
                    NpgsqlCommand cmd2 = new NpgsqlCommand(
                        "SELECT * FROM SignupDatabase(@id, @name, @contact, @adrs, @desig, @sal, @email, @usrn, @pass)", conn);
                    cmd2.Parameters.AddWithValue("@id", Convert.ToString(ans));
                    cmd2.Parameters.AddWithValue("@name", Name);
                    cmd2.Parameters.AddWithValue("@contact", Contact);
                    cmd2.Parameters.AddWithValue("@adrs", House);
                    cmd2.Parameters.AddWithValue("@desig", Designation);
                    cmd2.Parameters.AddWithValue("@sal", Salary);
                    cmd2.Parameters.AddWithValue("@email", Email);
                    cmd2.Parameters.AddWithValue("@usrn", UserN);
                    cmd2.Parameters.AddWithValue("@pass", Pass);
                    object result = cmd2.ExecuteScalar();
                    return Convert.ToInt32(result);
                }
                catch (NpgsqlException ex)
                {
                    Console.WriteLine("PG Error: " + ex.Message);
                    return -5;
                }
            }
        }

        public int customer(string id, string name, string mid, string quantity, string amount)
        {
            using (NpgsqlConnection conn = new NpgsqlConnection(connString))
            {
                conn.Open();
                try
                {
                    NpgsqlCommand cmd = new NpgsqlCommand(
                        "SELECT customer_database(@id, @name, @mid, @quantity, @amount)", conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@mid", mid);
                    cmd.Parameters.AddWithValue("@quantity", float.Parse(quantity));
                    cmd.Parameters.AddWithValue("@amount", float.Parse(amount));
                    cmd.ExecuteNonQuery();
                }
                catch (NpgsqlException ex)
                {
                    Console.WriteLine("PG Error: " + ex.Message);
                    return -5;
                }
            }
            return 0;
        }

        public int Bill(string id)
        {
            using (NpgsqlConnection conn = new NpgsqlConnection(connString))
            {
                conn.Open();
                try
                {
                    NpgsqlCommand cmd = new NpgsqlCommand("SELECT CustomerBill(@id)", conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                }
                catch (NpgsqlException ex)
                {
                    Console.WriteLine("PG Error: " + ex.Message);
                    return -5;
                }
            }
            return 0;
        }

        public int repetedcustomer(string id)
        {
            using (NpgsqlConnection conn = new NpgsqlConnection(connString))
            {
                conn.Open();
                try
                {
                    NpgsqlCommand cmd = new NpgsqlCommand("SELECT repetitionCustomercontrol(@id)", conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                }
                catch (NpgsqlException ex)
                {
                    Console.WriteLine("PG Error: " + ex.Message);
                    return -5;
                }
            }
            return 0;
        }

        public DataTable showbill()
        {
            return ExecuteQuery("SELECT * FROM Bill");
        }

        public int dealer(string PurchaseID, string DealerID, string Medicineid, string PurchaseDate, string Quantity, string price, string Totalprice)
        {
            using (NpgsqlConnection conn = new NpgsqlConnection(connString))
            {
                conn.Open();
                try
                {
                    NpgsqlCommand cmd = new NpgsqlCommand(
                        "SELECT Purchaseoutput(@pid, @did, @mid, @pdate::date, @qty, @price, @total)", conn);
                    cmd.Parameters.AddWithValue("@pid", PurchaseID);
                    cmd.Parameters.AddWithValue("@did", DealerID);
                    cmd.Parameters.AddWithValue("@mid", Medicineid);
                    cmd.Parameters.AddWithValue("@pdate", PurchaseDate);
                    cmd.Parameters.AddWithValue("@qty", float.Parse(Quantity));
                    cmd.Parameters.AddWithValue("@price", float.Parse(price));
                    cmd.Parameters.AddWithValue("@total", float.Parse(Totalprice));
                    cmd.ExecuteNonQuery();
                }
                catch (NpgsqlException ex)
                {
                    Console.WriteLine("PG Error: " + ex.Message);
                    return -5;
                }
            }
            return 0;
        }

        public DataTable showdealerbill()
        {
            return ExecuteQuery("SELECT * FROM DealerBill");
        }
    }
}
