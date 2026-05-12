CREATE DATABASE library_db;

USE library_db;

CREATE TABLE books (
    accession_no INT,
    book_title CHAR(100),
    author CHAR(100),
    price_inr DECIMAL(10,2),
    price_dollar DECIMAL(10,2),
    price_pound DECIMAL(10,2),
    publisher CHAR(100),
    status CHAR(20),
    donated CHAR(20),
    self_no CHAR(50),
    compartment_no INT,
    no_of_copy INT
);


desc books;
