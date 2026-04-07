-- PostgreSQL schema for Pharmacy application
-- Translated from SQL Server T-SQL

-- -------------------------------------------
-- Tables
-- -------------------------------------------

CREATE TABLE Company (
    CompanyID varchar(20) PRIMARY KEY,
    CompanyName varchar(40) NOT NULL,
    Location varchar(40) NOT NULL,
    ContactNumber varchar(11) NOT NULL
);

CREATE TABLE Medicine (
    MedicineID varchar(20) PRIMARY KEY,
    MedicineName varchar(25) NOT NULL,
    CompanyID varchar(20) REFERENCES Company(CompanyID) ON UPDATE CASCADE ON DELETE CASCADE,
    Price float NOT NULL,
    Manufacturing date NOT NULL,
    Expiry date NOT NULL
);

CREATE TABLE Dealer (
    DealerID varchar(20) PRIMARY KEY,
    Name varchar(40) NOT NULL,
    Contact varchar(11) NOT NULL,
    House varchar(40) NULL,
    CompanyID varchar(20) REFERENCES Company(CompanyID) ON UPDATE CASCADE ON DELETE CASCADE,
    Email varchar(25) UNIQUE CHECK (Email LIKE '%_@__%.__%'),
    Price float NOT NULL
);

CREATE TABLE Employ (
    EmpID varchar(20) PRIMARY KEY,
    EmpName varchar(40) NOT NULL,
    Contact varchar(11) NOT NULL,
    House varchar(40) NULL,
    Designation varchar(20) NULL,
    Salary int CHECK(Salary > 0),
    Email varchar(25) UNIQUE CHECK (Email LIKE '%_@__%.__%')
);

CREATE TABLE LoginTable (
    UserName varchar(20) NOT NULL,
    Pass varchar(20) NOT NULL,
    EmpID varchar(20) REFERENCES Employ(EmpID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Sales (
    MedicineID varchar(20) REFERENCES Medicine(MedicineID),
    SalesDate date NOT NULL,
    Quantity float NOT NULL,
    price float NOT NULL,
    Totalprice float NOT NULL
);

CREATE TABLE Purchase (
    PurchaseID varchar(20) PRIMARY KEY,
    DealerID varchar(20) REFERENCES Dealer(DealerID),
    Medicineid varchar(20) REFERENCES Medicine(MedicineID),
    PurchaseDate date NOT NULL,
    Quantity float NOT NULL,
    price float NOT NULL,
    Totalprice float NOT NULL
);

CREATE TABLE Stock (
    Productid varchar(20) REFERENCES Medicine(MedicineID) ON UPDATE CASCADE ON DELETE CASCADE,
    Quantityleft float NOT NULL
);

CREATE TABLE Customers (
    CustomerID varchar(20) PRIMARY KEY,
    CustomerName varchar(20) NOT NULL,
    Productid varchar(20) REFERENCES Medicine(MedicineID) ON UPDATE CASCADE ON DELETE CASCADE,
    Quantity float NOT NULL CHECK(Quantity > 0),
    price float NOT NULL
);

CREATE TABLE Bill (
    CustomerID varchar(20) REFERENCES Customers(CustomerID) ON UPDATE CASCADE ON DELETE CASCADE,
    InputPrice float NOT NULL,
    ReturnPrice float NOT NULL
);

CREATE TABLE Dealerbill (
    DealerID varchar(20) REFERENCES Dealer(DealerID) ON UPDATE CASCADE ON DELETE CASCADE,
    InputPrice float NOT NULL,
    ReturnPrice float NOT NULL
);

CREATE TABLE repeatedCustomers (
    CustomerID varchar(20) NOT NULL,
    Productid varchar(20) NOT NULL,
    Quantity float NOT NULL
);

CREATE TABLE orgCustomers (
    CustomerID varchar(20) PRIMARY KEY,
    CustomerName varchar(20),
    Productid varchar(20) REFERENCES Medicine(MedicineID) ON UPDATE CASCADE ON DELETE CASCADE,
    Quantity float,
    price float
);

CREATE TABLE virtualStock (
    Productid varchar(20) REFERENCES Medicine(MedicineID) ON UPDATE CASCADE ON DELETE CASCADE,
    Quantityleft float
);

-- -------------------------------------------
-- Stored Procedures (as PL/pgSQL functions returning tables/values)
-- -------------------------------------------

-- In PostgreSQL, procedures that return result sets must be functions
-- returning SETOF or TABLE. Procedures with OUTPUT params use INOUT.

CREATE OR REPLACE FUNCTION Find_Dealer(p_id varchar)
RETURNS TABLE(DealerID varchar, Name varchar, Contact varchar, House varchar, CompanyID varchar, Email varchar, Price float) AS $$
BEGIN
    RETURN QUERY SELECT D.DealerID, D.Name, D.Contact, D.House, D.CompanyID, D.Email, D.Price FROM Dealer D WHERE D.DealerID = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Find_Employ(p_id varchar)
RETURNS TABLE(EmpID varchar, EmpName varchar, Contact varchar, House varchar, Designation varchar, Salary int, Email varchar) AS $$
BEGIN
    RETURN QUERY SELECT E.EmpID, E.EmpName, E.Contact, E.House, E.Designation, E.Salary, E.Email FROM Employ E WHERE E.EmpID = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Find_Employ_Name(p_name varchar)
RETURNS TABLE(EmpID varchar, EmpName varchar, Contact varchar, House varchar, Designation varchar, Salary int, Email varchar) AS $$
BEGIN
    RETURN QUERY SELECT E.EmpID, E.EmpName, E.Contact, E.House, E.Designation, E.Salary, E.Email FROM Employ E WHERE E.EmpName = p_name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Find_Price(p_id varchar)
RETURNS TABLE(MedicineName varchar, Price float) AS $$
BEGIN
    RETURN QUERY SELECT M.MedicineName, M.Price FROM Medicine M WHERE M.MedicineID = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Find_Expiry(p_id varchar)
RETURNS TABLE(MedicineName varchar, Expiry date) AS $$
BEGIN
    RETURN QUERY SELECT M.MedicineName, M.Expiry FROM Medicine M WHERE M.MedicineID = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Who_took_these(p_id varchar)
RETURNS TABLE(Productid varchar, CustomerName varchar) AS $$
BEGIN
    RETURN QUERY SELECT C.Productid, C.CustomerName FROM Customers C WHERE C.Productid = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Find_All_Info(p_id varchar)
RETURNS TABLE(MedicineName varchar, CompanyName varchar, ContactNumber varchar, Price float, Manufacturing date, Expiry date) AS $$
BEGIN
    RETURN QUERY
    SELECT M.MedicineName, C.CompanyName, C.ContactNumber, M.Price, M.Manufacturing, M.Expiry
    FROM Medicine M JOIN Company C ON M.CompanyID = C.CompanyID
    WHERE M.MedicineID = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Quantityleft(p_id varchar)
RETURNS TABLE(MedicineName varchar, Quantityleft float) AS $$
BEGIN
    RETURN QUERY
    SELECT M.MedicineName, Q.Quantityleft
    FROM Medicine M, Stock Q
    WHERE Q.Productid = p_id AND M.MedicineID = Q.Productid;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION PurchaseDates(p_id varchar)
RETURNS TABLE(Medicineid varchar, PurchaseDate date) AS $$
BEGIN
    RETURN QUERY SELECT P.Medicineid, P.PurchaseDate FROM Purchase P WHERE P.Medicineid = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CompanyName(p_id varchar)
RETURNS TABLE(CompanyID varchar, CompanyName varchar) AS $$
BEGIN
    RETURN QUERY SELECT C.CompanyID, C.CompanyName FROM Company C WHERE C.CompanyID = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION DealernamefromCompID(p_id varchar)
RETURNS TABLE(DealerID varchar, Name varchar) AS $$
BEGIN
    RETURN QUERY SELECT D.DealerID, D.Name FROM Dealer D WHERE D.CompanyID = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Show_All_Expired()
RETURNS TABLE(MedicineID varchar, MedicineName varchar, "Expired on" date) AS $$
BEGIN
    RETURN QUERY
    SELECT M.MedicineID, M.MedicineName, M.Expiry
    FROM Medicine M
    WHERE (CURRENT_DATE - M.Expiry) > 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Show_outofstock()
RETURNS TABLE(MedicineID varchar, MedicineName varchar) AS $$
BEGIN
    RETURN QUERY
    SELECT M.MedicineID, M.MedicineName
    FROM Medicine M JOIN Stock S ON M.MedicineID = S.Productid
    WHERE S.Quantityleft = 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Show_All_Medicine()
RETURNS TABLE(MedicineID varchar, MedicineName varchar, CompanyID varchar, Price float, Manufacturing date, Expiry date) AS $$
BEGIN
    RETURN QUERY SELECT M.MedicineID, M.MedicineName, M.CompanyID, M.Price, M.Manufacturing, M.Expiry FROM Medicine M;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION noOfSale(p_id varchar)
RETURNS TABLE(MedicineID varchar, Quantity float, price float, Totalprice float) AS $$
BEGIN
    RETURN QUERY SELECT S.MedicineID, S.Quantity, S.price, S.Totalprice FROM Sales S WHERE S.MedicineID = p_id;
END;
$$ LANGUAGE plpgsql;

-- Procedures with OUTPUT parameters → use INOUT in PL/pgSQL

CREATE OR REPLACE FUNCTION LoginDatabase(p_usr varchar, p_pas varchar, INOUT p_ans int DEFAULT 0)
AS $$
DECLARE
    stored_pass varchar;
BEGIN
    SELECT Pass INTO stored_pass FROM LoginTable WHERE UserName = p_usr;
    IF stored_pass = p_pas THEN
        p_ans := 1;
    ELSE
        p_ans := 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetLastID(INOUT p_ans int DEFAULT 0)
AS $$
BEGIN
    SELECT COALESCE(MAX(CAST(EmpID AS INT)), 0) INTO p_ans FROM Employ;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION SignupDatabase(
    p_id varchar, p_name varchar, p_contact varchar, p_adrs varchar,
    p_desig varchar, p_sal int, p_Email varchar, p_usrn varchar,
    p_pass varchar, INOUT p_output int DEFAULT 0
) AS $$
DECLARE
    existing_user varchar;
BEGIN
    SELECT UserName INTO existing_user FROM LoginTable WHERE UserName = p_usrn;
    IF existing_user IS NOT NULL THEN
        p_output := 0;
    ELSE
        INSERT INTO Employ VALUES (p_id, p_name, p_contact, p_adrs, p_desig, p_sal, p_Email);
        INSERT INTO LoginTable VALUES (p_usrn, p_pass, p_id);
        p_output := 1;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Update_Expiry(p_d date, p_id varchar)
RETURNS TABLE(MedicineName varchar, Expiry date) AS $$
DECLARE
    mag date;
BEGIN
    SELECT Manufacturing INTO mag FROM Medicine WHERE MedicineID = p_id;
    IF (p_d - mag) < 0 THEN
        RAISE NOTICE 'Invalid Expiry as it is less than manufacturing date';
    ELSE
        UPDATE Medicine SET Expiry = p_d WHERE MedicineID = p_id;
        RETURN QUERY SELECT M.MedicineName, M.Expiry FROM Medicine M WHERE M.MedicineID = p_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Update_Manf(p_d date, p_id varchar)
RETURNS TABLE(MedicineName varchar, Manufacturing date) AS $$
DECLARE
    exp date;
BEGIN
    SELECT Medicine.Expiry INTO exp FROM Medicine WHERE MedicineID = p_id;
    IF (exp - p_d) < 0 THEN
        RAISE NOTICE 'Invalid Manufacturing as it is greater than expiry date';
    ELSE
        UPDATE Medicine SET Manufacturing = p_d WHERE MedicineID = p_id;
        RETURN QUERY SELECT M.MedicineName, M.Manufacturing FROM Medicine M WHERE M.MedicineID = p_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION customer_database(p_id varchar, p_name varchar, p_mid varchar, p_quantity float, p_price float)
RETURNS void AS $$
BEGIN
    INSERT INTO Customers VALUES (p_id, p_name, p_mid, p_quantity, p_price);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION InsertCustomer(p_id varchar, p_name varchar, p_Productid varchar, p_Quantity float, p_price float)
RETURNS void AS $$
BEGIN
    INSERT INTO Customers VALUES (p_id, p_name, p_Productid, p_Quantity, p_price);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Show_If_Expired(p_id varchar)
RETURNS void AS $$
DECLARE
    dateofmed date;
BEGIN
    SELECT Expiry INTO dateofmed FROM Medicine WHERE MedicineID = p_id;
    IF (CURRENT_DATE - dateofmed) > 0 THEN
        RAISE NOTICE 'This Medicine is expired';
    ELSE
        RAISE NOTICE 'This Medicine is not expired';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CustomerBill(p_id varchar)
RETURNS void AS $$
DECLARE
    cus varchar(20);
    total_sum float := 0;
    sum2 float := 0;
    cust_name varchar(20);
    med varchar(20);
    qu float;
    pr float;
    finalsum float := 0;
    pric float;
    remain float := 0;
    quan float;
    mi varchar(20);
    stockquantity float;
BEGIN
    SELECT CustomerName, Productid, Quantity, price INTO cust_name, med, qu, pr
    FROM Customers WHERE CustomerID = p_id;

    SELECT COALESCE(SUM(C.Quantity * M.Price), 0) INTO total_sum
    FROM Customers C, Medicine M
    WHERE C.CustomerID = p_id AND M.MedicineID = C.Productid;

    SELECT CustomerID INTO cus FROM repeatedCustomers WHERE CustomerID = p_id LIMIT 1;

    IF cus IS NOT NULL THEN
        SELECT COALESCE(SUM(C.Quantity * M.Price), 0) INTO sum2
        FROM repeatedCustomers C, Medicine M
        WHERE C.CustomerID = cus AND M.MedicineID = C.Productid;
    END IF;

    finalsum := total_sum + sum2;

    SELECT price INTO pric FROM Customers WHERE CustomerID = p_id;

    remain := pric - finalsum;

    IF remain >= 0 THEN
        SELECT Quantityleft, Productid INTO quan, mi FROM virtualStock LIMIT 1;
        DELETE FROM virtualStock;
        UPDATE Stock SET Quantityleft = quan WHERE Productid = mi;
        INSERT INTO Bill VALUES (p_id, pric, remain);
    ELSE
        DELETE FROM repeatedCustomers WHERE CustomerID = p_id;
        DELETE FROM Customers WHERE CustomerID = p_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION repetitionCustomercontrol(p_id varchar)
RETURNS void AS $$
DECLARE
    cust_name varchar(20);
    med varchar(20);
    qu float;
    pr float;
BEGIN
    SELECT CustomerName, Productid, Quantity, price INTO cust_name, med, qu, pr
    FROM Customers WHERE CustomerID = p_id;
    INSERT INTO orgCustomers VALUES (p_id, cust_name, med, qu, pr);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Purchaseoutput(
    p_PurchaseID varchar, p_DealerID varchar, p_Medicineid varchar,
    p_PurchaseDate date, p_Quantity float, p_price float, p_Totalprice float
) RETURNS void AS $$
BEGIN
    INSERT INTO Purchase VALUES (p_PurchaseID, p_DealerID, p_Medicineid, p_PurchaseDate, p_Quantity, p_price, p_Totalprice);
END;
$$ LANGUAGE plpgsql;

-- -------------------------------------------
-- Trigger Functions
-- -------------------------------------------

-- Stock update on purchase insert
CREATE OR REPLACE FUNCTION fn_forStock() RETURNS TRIGGER AS $$
DECLARE
    qty float;
BEGIN
    IF EXISTS (SELECT 1 FROM Stock WHERE Productid = NEW.Medicineid) THEN
        UPDATE Stock SET Quantityleft = Quantityleft + NEW.Quantity WHERE Productid = NEW.Medicineid;
    ELSE
        INSERT INTO Stock VALUES (NEW.Medicineid, NEW.Quantity);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER forStock AFTER INSERT ON Purchase
FOR EACH ROW EXECUTE FUNCTION fn_forStock();

-- Sales update on customer insert
CREATE OR REPLACE FUNCTION fn_forSales() RETURNS TRIGGER AS $$
DECLARE
    med_price float;
    tprice float;
BEGIN
    SELECT price INTO med_price FROM Medicine WHERE MedicineID = NEW.Productid;
    tprice := med_price * NEW.Quantity;
    IF EXISTS (SELECT 1 FROM Sales WHERE MedicineID = NEW.Productid) THEN
        UPDATE Sales SET Quantity = Quantity + NEW.Quantity WHERE MedicineID = NEW.Productid;
        UPDATE Sales SET Totalprice = Totalprice + tprice WHERE MedicineID = NEW.Productid;
    ELSE
        INSERT INTO Sales VALUES (NEW.Productid, CURRENT_DATE, NEW.Quantity, NEW.price, tprice);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER forSales AFTER INSERT ON Customers
FOR EACH ROW EXECUTE FUNCTION fn_forSales();

-- Note: The INSTEAD OF triggers (Valid_Email, Valid_Expiry_Insert,
-- billcalculation, Valid_Dealer_Purchase_Price) are SQL Server-specific.
-- PostgreSQL supports INSTEAD OF triggers only on views, not tables.
-- The validation logic is handled by CHECK constraints and the
-- stored procedure layer instead.

-- -------------------------------------------
-- Seed Data
-- -------------------------------------------

INSERT INTO Company VALUES ('10C', 'ABC', 'Lahore', '12345');
INSERT INTO Company VALUES ('11C', 'DEF', 'Karachi', '45678');
INSERT INTO Company VALUES ('12C', 'GHI', 'Karachi', '32242');

INSERT INTO Medicine VALUES ('12M', 'Paracetamol', '10C', 20, '2018-01-10', '2025-04-08');
INSERT INTO Medicine VALUES ('11M', 'Ibuprofen', '11C', 30, '2018-01-10', '2025-04-18');
INSERT INTO Medicine VALUES ('13M', 'Amoxicillin', '12C', 45, '2019-03-15', '2026-03-15');

INSERT INTO Employ VALUES ('3', 'Saqib', '03216773647', 'FaisalTown', 'Manager', 1000, 'Saqib@gmail.com');
INSERT INTO Employ VALUES ('2', 'Umair', '03368802220', 'FaisalTown', 'Manager', 1000, 'Umair@gmail.com');

INSERT INTO LoginTable VALUES ('Mian', 'Mian1122', '3');
INSERT INTO LoginTable VALUES ('Lucky', 'Luckydon', '2');

INSERT INTO Dealer VALUES ('11D', 'Hamza', '0300126453', 'ABC', '10C', 'Hamza@gmail.com', 50);
INSERT INTO Dealer VALUES ('10D', 'Ali', '0300126454', 'DEF', '11C', 'Ali@gmail.com', 60);

INSERT INTO Stock VALUES ('12M', 500);
INSERT INTO Stock VALUES ('11M', 300);
INSERT INTO Stock VALUES ('13M', 200);

INSERT INTO Sales VALUES ('12M', '2024-01-15', 50, 20, 1000);
INSERT INTO Sales VALUES ('11M', '2024-01-20', 30, 30, 900);

-- Purchases (forStock trigger will fire and update Stock)
INSERT INTO Purchase VALUES ('15P', '11D', '12M', '2018-01-17', 1000, 40, 40000);
INSERT INTO Purchase VALUES ('13P', '11D', '11M', '2018-01-12', 10, 50, 500);
INSERT INTO Purchase VALUES ('12P', '10D', '11M', '2018-01-12', 10, 50, 500);
