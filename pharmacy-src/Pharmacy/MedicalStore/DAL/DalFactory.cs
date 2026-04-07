using System;

namespace MedicalStore.DAL
{
    /// <summary>
    /// Factory that returns the appropriate DAL class based on appSettings["DbDriver"].
    /// Both myClass (SqlClient) and myClassPg (Npgsql) have identical method signatures,
    /// so callers use dynamic to avoid needing an interface.
    /// </summary>
    public static class DalFactory
    {
        public static dynamic Create()
        {
            string driver = System.Configuration.ConfigurationManager.AppSettings["DbDriver"] ?? "sqlserver";
            if (driver.ToLower() == "pg" || driver.ToLower() == "postgres")
            {
                return new myClassPg();
            }
            return new myClass();
        }
    }
}
