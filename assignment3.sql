-- ============================
-- SCHEMA CREATION
-- ============================

CREATE TABLE Hotel (
    Hotel_No INT PRIMARY KEY,
    Name VARCHAR(100),
    City VARCHAR(50)
);

CREATE TABLE Room (
    Room_No INT,
    Hotel_No INT,
    Type CHAR(1), -- S = Single, N = Family
    Price DECIMAL(10,2),
    PRIMARY KEY (Room_No, Hotel_No),
    FOREIGN KEY (Hotel_No) REFERENCES Hotel(Hotel_No)
);

CREATE TABLE Guest (
    Guest_No INT PRIMARY KEY,
    Name VARCHAR(100),
    City VARCHAR(50)
);

CREATE TABLE Booking (
    Hotel_No INT,
    Room_No INT,
    Guest_No INT,
    Date_From DATE,
    Date_To DATE,
    PRIMARY KEY (Hotel_No, Room_No, Guest_No, Date_From),
    FOREIGN KEY (Hotel_No, Room_No) REFERENCES Room(Room_No, Hotel_No),
    FOREIGN KEY (Guest_No) REFERENCES Guest(Guest_No)
);

-- ============================
-- QUERIES
-- ============================

-- 1. List full details of all hotels
SELECT * FROM Hotel;

-- 2. List full details of all hotels in New York
SELECT * FROM Hotel WHERE City = 'New York';

-- 3. List names and cities of all guests ordered by city
SELECT Name, City FROM Guest ORDER BY City;

-- 4. Family rooms in ascending order of price
SELECT * FROM Room WHERE Type = 'N' ORDER BY Price ASC;

-- 5. Number of hotels
SELECT COUNT(*) AS NumHotels FROM Hotel;

-- 6. Distinct cities of guests
SELECT DISTINCT City FROM Guest;

-- 7. Average price of a room
SELECT AVG(Price) AS AvgRoomPrice FROM Room;

-- 8. Hotel names, room numbers, and type
SELECT h.Name, r.Room_No, r.Type
FROM Hotel h JOIN Room r ON h.Hotel_No = r.Hotel_No;

-- 9. Hotel names, booking dates, and room numbers for New York hotels
SELECT h.Name, b.Date_From, b.Date_To, b.Room_No
FROM Hotel h JOIN Booking b ON h.Hotel_No = b.Hotel_No
WHERE h.City = 'New York';

-- 10. Number of bookings started in September
SELECT COUNT(*) AS SeptBookings
FROM Booking
WHERE MONTH(Date_From) = 9;

-- 11. Guests who began a stay in New York in August
SELECT g.Name, g.City
FROM Guest g JOIN Booking b ON g.Guest_No = b.Guest_No
JOIN Hotel h ON b.Hotel_No = h.Hotel_No
WHERE h.City = 'New York' AND MONTH(b.Date_From) = 8;

-- 12. Hotel rooms not booked
SELECT h.Name, r.Room_No
FROM Hotel h JOIN Room r ON h.Hotel_No = r.Hotel_No
WHERE NOT EXISTS (
    SELECT 1 FROM Booking b
    WHERE b.Hotel_No = r.Hotel_No AND b.Room_No = r.Room_No
);

-- 13. Hotel with highest priced room
SELECT h.Name, h.City
FROM Hotel h JOIN Room r ON h.Hotel_No = r.Hotel_No
ORDER BY r.Price DESC
LIMIT 1;

-- 14. Hotels with rooms cheaper than lowest Boston room
SELECT h.Name, r.Room_No, h.City, r.Price
FROM Hotel h JOIN Room r ON h.Hotel_No = r.Hotel_No
WHERE r.Price < (
    SELECT MIN(r2.Price)
    FROM Room r2 JOIN Hotel h2 ON r2.Hotel_No = h2.Hotel_No
    WHERE h2.City = 'Boston'
);

-- 15. Average price of a room grouped by city
SELECT h.City, AVG(r.Price) AS AvgPrice
FROM Hotel h JOIN Room r ON h.Hotel_No = r.Hotel_No
GROUP BY h.City;
