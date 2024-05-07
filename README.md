This project is aimed to clean the Housing sale data step by step after importing it into MSSQL database table from Excel

## Process

1. Standardize Date Format - The datatype of 'SaleDate' column when imported is 'Datetime' and the column values includes timestamps as yyyy-mm-dd 00:00:00. To make the date value readable and usable, a new column 'SaleDateConverted' is created with 'Date' as datatype and 'SaleDate' values were converted to 'Date' type and inserted into the new column. Now the date values are standardized to yyyy-mm-dd format.
2. Its noted for few housing properties there were two records with identical 'Sale ID' but one with a NULL value for PropertyAddress'. This query populates the property address for a null value record from the other record that has a value in it.
3. Property address stored in one column as '<Property No> <Street Addr>, <County>' is split into 3 columns as 'Address', 'City' and 'State'. The address is now more readable and easy to handle it in SQL queries.
4. The column "Sold as Vacant" stores a boolean value 'Y' for Yes and 'N' for No. The values are updated from 'Y' to 'Yes' AND 'N' to 'No'. This makes the values more readable.
5. There were duplicate records identified for one sale of a property. Duplicate records identified and removed.
6. Unused columns are deleted.
