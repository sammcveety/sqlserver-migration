using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;

namespace MedicalStore
{
    public partial class Outputpage2 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Did"].ToString() == "1")
            {
                dynamic userDal = DAL.DalFactory.Create();
                DataTable table = new DataTable();
                table = userDal.showalldealers();
                GridView1.DataSource = table;
                GridView1.EmptyDataText = "No Records Found";
                GridView1.DataBind();
            }
            else if (Session["Did"].ToString() == "2")
            {
                dynamic userDal = DAL.DalFactory.Create();
                DataTable table = new DataTable();
                table = userDal.showallcompanies();
                GridView1.DataSource = table;
                GridView1.EmptyDataText = "No Records Found";
                GridView1.DataBind();
            }
            else if (Session["Did"].ToString() == "3")
            {
                dynamic userDal = DAL.DalFactory.Create();
                DataTable table = new DataTable();
                table = userDal.showallpurchases();
                GridView1.DataSource = table;
                GridView1.EmptyDataText = "No Records Found";
                GridView1.DataBind();
            }
            else if (Session["Did"].ToString() == "4")
            {
                dynamic userDal = DAL.DalFactory.Create();
                DataTable table = new DataTable();
                table = userDal.showallsales();
                GridView1.DataSource = table;
                GridView1.EmptyDataText = "No Records Found";
                GridView1.DataBind();
            }
            else if (Session["Did"].ToString() == "5")
            {
                dynamic userDal = DAL.DalFactory.Create();
                DataTable table = new DataTable();
                table = userDal.searchdealerbyid(Session["Did2"].ToString());
                GridView1.DataSource = table;
                GridView1.EmptyDataText = "No Records Found";
                GridView1.DataBind();
            }
            else if (Session["Did"].ToString() == "6")
            {
                dynamic userDal = DAL.DalFactory.Create();
                DataTable table = new DataTable();
                table = userDal.DealernamefromCompID(Session["Did2"].ToString());
                GridView1.DataSource = table;
                GridView1.EmptyDataText = "No Records Found";
                GridView1.DataBind();
            }
        }
    }
}