-- Triggers for Pharmacy database
-- Cleaned up from original Triggers.sql

-- Prevent dropping tables
CREATE TRIGGER PreventDropTables
ON DATABASE FOR DROP_TABLE
AS BEGIN
    RAISERROR ('You cannot Drop any Table (Trigger Name "PreventDropTables")',10,1);
    ROLLBACK
END
GO

-- Adds new medicines in stock after purchase from dealer
CREATE TRIGGER forStock ON Purchase
FOR INSERT
AS BEGIN
    DECLARE @quantity int;
    DECLARE @medid varchar(20);
    SELECT @medid = Medicineid FROM inserted
    SELECT @quantity = Quantity FROM inserted
    IF((SELECT Quantityleft FROM Stock WHERE Productid = @medid) >= 0)
    BEGIN
        UPDATE Stock
        SET Quantityleft = Quantityleft + @quantity
        WHERE Productid = @medid
    END
    ELSE
    BEGIN
        INSERT INTO [Stock]
        VALUES (@medid, @quantity)
    END
END
GO

-- Adds sold medicine to sales list when customer is inserted
CREATE TRIGGER forSales ON Customers
FOR INSERT
AS BEGIN
    DECLARE @quantity int;
    DECLARE @medid varchar(20);
    DECLARE @Cdate date;
    DECLARE @price int;
    DECLARE @tprice int;
    SELECT @medid = Productid FROM inserted;
    SELECT @quantity = Quantity FROM inserted;
    SELECT @Cdate = GETDATE();
    SELECT @price = price FROM inserted;
    DECLARE @p float;
    SELECT @p = price FROM Medicine WHERE MedicineID = @medid
    SELECT @tprice = @p * @quantity
    IF((SELECT Quantity FROM Sales WHERE MedicineID = @medid) >= 0)
    BEGIN
        UPDATE Sales
        SET Quantity = Quantity + @quantity
        WHERE MedicineID = @medid;
        UPDATE Sales
        SET Totalprice = Totalprice + @tprice
        WHERE MedicineID = @medid;
    END
    ELSE
    BEGIN
        INSERT INTO [Sales]
        VALUES (@medid, @Cdate, @quantity, @price, @tprice)
    END
END
GO

-- Validate email format on employee insert/update
CREATE TRIGGER Valid_Email ON Employ
INSTEAD OF INSERT, UPDATE
AS BEGIN
    DECLARE @email varchar(25);
    SELECT @email = i.Email FROM inserted i;
    IF @email NOT LIKE '%_@__%.__%'
    BEGIN
        PRINT 'Invalid Email... (Trigger Name "Valid_Email")';
        ROLLBACK
    END
    ELSE
    BEGIN
        INSERT INTO [Employ]
        SELECT EmpID, EmpName, Contact, House, Designation, Salary, Email FROM inserted
    END
END
GO

-- Validate expiry date on medicine insert
CREATE TRIGGER Valid_Expiry_Insert ON Medicine
INSTEAD OF INSERT
AS BEGIN
    DECLARE @exp Date;
    DECLARE @mag Date;
    SELECT @exp = Expiry FROM inserted;
    SELECT @mag = Manufacturing FROM inserted;
    IF (DATEDIFF(day, @mag, @exp) < 0)
    BEGIN
        PRINT 'Invalid Expiry as it is less than manufacturing date of medicine (Trigger Name "Valid_Expiry")';
        ROLLBACK
    END
    ELSE
    BEGIN
        INSERT INTO [Medicine]
        SELECT MedicineID, MedicineName, CompanyID, Price, Manufacturing, Expiry FROM inserted
    END
END
GO

-- Validate dealer purchase price
CREATE TRIGGER Valid_Dealer_Purchase_Price ON Purchase
INSTEAD OF INSERT
AS BEGIN
    DECLARE @price float;
    DECLARE @quan float;
    DECLARE @purchaseprice float;
    SELECT @quan = Quantity FROM inserted
    DECLARE @purchaseprice2 float;
    DECLARE @price2 float;
    DECLARE @idd varchar(20);
    DECLARE @cmpid varchar(20);
    DECLARE @med varchar(20);
    SELECT @med = Medicineid FROM inserted
    SELECT @price = price FROM inserted;
    SELECT @idd = Dealerid FROM inserted;
    SELECT @cmpid = companyid FROM Dealer WHERE @idd = Dealerid
    SET @purchaseprice = (@quan * @price);
    SELECT @price2 = NULL
    SELECT @price2 = price
    FROM Medicine
    WHERE Companyid = @cmpid AND MedicineID = @med
    SET @purchaseprice2 = (@quan * @price2);
    IF(@purchaseprice >= @purchaseprice2)
    BEGIN
        DECLARE @return float;
        SELECT @return = @purchaseprice - @purchaseprice2
        INSERT INTO Purchase SELECT * FROM inserted
        DELETE FROM Dealerbill
        INSERT INTO [Dealerbill]
        VALUES(@idd, @purchaseprice, @return)
    END
END
GO

-- Customer billing trigger (INSTEAD OF INSERT on Customers)
CREATE TRIGGER billcalculation ON Customers
INSTEAD OF INSERT
AS BEGIN
    DELETE FROM bill
    DECLARE @finalquantity float;
    DECLARE @price2 varchar(20);
    SET @price2 = NULL;
    DECLARE @idd varchar(20);
    SET @idd = NULL;
    DECLARE @Cid varchar(20);
    DECLARE @mid varchar(20);
    SELECT @mid = Productid FROM inserted
    DECLARE @quantity float;
    DECLARE @cusquantity float;
    SELECT @cusquantity = Quantity FROM inserted
    SELECT @Cid = CustomerID FROM inserted
    SELECT @idd = CustomerID FROM Customers WHERE @Cid = CustomerID
    SELECT @quantity = Quantityleft
    FROM Stock S
    WHERE S.Productid = @mid
    DECLARE @orgcus varchar(20)
    SELECT @orgcus = CustomerID FROM orgCustomers
    WHERE CustomerID = @Cid
    IF (@orgcus = @Cid)
    BEGIN
        PRINT 'Customer ID Already Exists'
    END
    ELSE IF (@quantity < @cusquantity)
    BEGIN
        PRINT 'Not In Stock The Given Quantity of Medicine'
    END
    ELSE IF (@idd IS NULL)
    BEGIN
        SET @finalquantity = @quantity - @cusquantity
        DELETE FROM [virtualstock]
        INSERT INTO [virtualstock]
        VALUES (@mid, @finalquantity)
        INSERT INTO Customers SELECT * FROM inserted
    END
    ELSE
    BEGIN
        SELECT @quantity = Quantityleft
        FROM virtualStock
        SET @finalquantity = @quantity - @cusquantity
        UPDATE virtualstock SET Quantityleft = @finalquantity WHERE Productid = @mid
        INSERT INTO repeatedCustomers SELECT CustomerID, Productid, Quantity FROM inserted
    END
END
GO
