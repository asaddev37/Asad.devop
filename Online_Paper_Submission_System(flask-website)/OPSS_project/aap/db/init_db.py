import mysql.connector

MYSQL_HOST = 'localhost'
MYSQL_USER = 'root'
MYSQL_PASSWORD = 'ak37'
MYSQL_DB = 'app1_database'

def get_db():
    """Establishes a connection to the MySQL database."""
    conn = mysql.connector.connect(
        host=MYSQL_HOST,
        user=MYSQL_USER,
        password=MYSQL_PASSWORD,
        database=MYSQL_DB
    )
    return conn

def create_database_tables():
    """Creates the specified database tables."""

    try:
        # Connect to the MySQL database
        conn = get_db()
        mycursor = conn.cursor()

        # SQL statements to create tables
        sql_statements = [
        #   """
        #     CREATE TABLE Author (
        #         Author_ID INT AUTO_INCREMENT PRIMARY KEY,
        #         Name VARCHAR(255),
        #         Affiliation VARCHAR(255),
        #         Tel_No VARCHAR(20),
        #         Email_Address VARCHAR(255),
        #         Postal_Address VARCHAR(255)
        #     );
        #     """,
#         """
#        CREATE TABLE Paper (
#     Paper_ID INT AUTO_INCREMENT PRIMARY KEY,  -- Unique identifier for each paper
#     Title VARCHAR(255),                       -- Title of the paper
#     Abstract TEXT,                            -- Abstract of the paper
#     Keywords VARCHAR(255),                    -- Keywords associated with the paper
#     Paper_Type VARCHAR(50),                   -- Type of the paper (e.g., research, review, etc.)
#     Submission_Date DATE,                     -- Submission date of the paper
#     File_Name VARCHAR(200),                   -- File name of the paper
#     Status VARCHAR(50) DEFAULT 'Pending Review', -- Default status of the paper
#     Author_ID INT,                            -- Foreign key referencing Author table
#     Access_Pin VARCHAR(5),                   -- Pin used to access the paper
#     FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID) -- Establish foreign key relationship
#       );
# """,


                        #         """
                        #   ALTER TABLE Paper ADD Access_Pin VARCHAR(5) NOT NULL;

                        #         """
                     """
                    """
                    
                        #   ALTER TABLE Reviewer ADD COLUMN Pin VARCHAR(5) NOT NULL;
                     
            #         """

            #          SELECT * FROM Paper WHERE Paper_ID = 1 AND Access_Pin = '12345';

            #    """
            #                """
            # CREATE TABLE Reviewer (
            #     Reviewer_ID INT AUTO_INCREMENT PRIMARY KEY,
            #     Name VARCHAR(255),
            #     Specialization VARCHAR(255),
            #     Max_Papers INT,
            #     Email VARCHAR(255) UNIQUE,
            #     Pin VARCHAR(5)   UNIQUE
                 
            # );
            #  """
            #  """
            # CREATE TABLE reviews (
            #     Review_ID INT AUTO_INCREMENT PRIMARY KEY,
            #     Paper_ID INT,
            #     Reviewer_ID INT,
            #     Quality_Score INT,
            #     Comments TEXT,
            #     Submitted_At DATETIME DEFAULT CURRENT_TIMESTAMP,
            #     FOREIGN KEY (Paper_ID) REFERENCES Paper(Paper_ID),
            #     FOREIGN KEY (Reviewer_ID) REFERENCES Reviewer(Reviewer_ID)
            # );
            #  """
#              """
#                  CREATE TABLE reviews (
#     id INT AUTO_INCREMENT PRIMARY KEY, -- Primary key renamed to 'id'
#     assignment_id INT , -- Foreign key for assignments
#     paper_id INT , -- Foreign key for paper
#     reviewer_id INT , -- Foreign key for reviewer
#     quality_score INT, -- Score field for quality
#     comments TEXT, -- Comments field
#     submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- Default timestamp for submission
#     FOREIGN KEY (assignment_id) REFERENCES assignments(id), -- Foreign key reference to assignments
#     FOREIGN KEY (paper_id) REFERENCES paper(Paper_ID), -- Foreign key reference to paper
#     FOREIGN KEY (reviewer_id) REFERENCES reviewer(Reviewer_ID) -- Foreign key reference to reviewer
# );

#              """
#  """
# CREATE TABLE reviews (
#     id INT AUTO_INCREMENT PRIMARY KEY, -- Primary key renamed to 'id'
#     assignment_id INT , -- Foreign key for assignments
#     paper_id INT NOT NULL, -- Foreign key for paper
#     reviewer_id INT NOT NULL, -- Foreign key for reviewer
#     quality_score INT, -- Score field for quality
#     comments TEXT, -- Comments field
#     submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- Default timestamp for submission
#     FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE, -- Foreign key reference to assignments
#     FOREIGN KEY (paper_id) REFERENCES paper(Paper_ID) ON DELETE CASCADE, -- Foreign key reference to paper
#     FOREIGN KEY (reviewer_id) REFERENCES reviewer(Reviewer_ID) ON DELETE CASCADE -- Foreign key reference to reviewer
# );


# """
# """
# UPDATE Reviews
# SET assignment_id = (
#     SELECT id FROM Assignments
#     WHERE assignments.paper_id = reviews.paper_id
#     AND assignments.reviewer_id = reviews.reviewer_id
# )
# WHERE assignment_id IS NULL;    

# """
#    """
# SELECT Paper.Paper_ID, Paper.Title, Paper.Abstract, Paper.Keywords, Paper.Paper_Type, 
#        Paper.Submission_Date, Paper.File_Name, Paper.Status, Paper.Author_ID, 
#        Paper.Access_Pin, Author.Name AS Author_Name
# FROM Paper
# JOIN Author ON Paper.Author_ID = Author.Author_ID
# WHERE TRIM(Paper.Access_Pin) = TRIM(%s);

#    """
# """
# DESCRIBE contact;

# """


            """
            CREATE TABLE ConferenceDetails (
                ID INT AUTO_INCREMENT PRIMARY KEY,
                Paper_ID INT,
                Presentation_Time DATETIME,
                Location VARCHAR(255),
                FOREIGN KEY (Paper_ID) REFERENCES Paper(Paper_ID)
            );
            """

#             """
#                 ALTER TABLE paper ADD COLUMN file_name VARCHAR(200);
#             """,
#             """
#                 ALTER TABLE paper ADD COLUMN status VARCHAR(50) DEFAULT 'Pending Review';
#             """,
            # """
            #     CREATE TABLE contact (
            #     Contact_ID INT AUTO_INCREMENT PRIMARY KEY,
            #     Name VARCHAR(255),
            #     Email VARCHAR(255),
            #     Message TEXT
            # );
            # """

# """
# CREATE TABLE Assignments (
#     id INT AUTO_INCREMENT PRIMARY KEY,
#     paper_id INT NOT NULL,
#     reviewer_id INT NOT NULL,
#     assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
#     FOREIGN KEY (paper_id) REFERENCES Paper(Paper_ID) ON DELETE CASCADE,
#     FOREIGN KEY (reviewer_id) REFERENCES Reviewer(Reviewer_ID) ON DELETE CASCADE,
#      Author_ID INT,
#     FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID) ON DELETE CASCADE

# );
#  """
# # #  
#  """
#  UPDATE Assignments
# SET Author_ID = (
#     SELECT author_id
#     FROM paper
#     WHERE paper.Paper_ID = Assignments.paper_id
# )
# WHERE Author_ID IS NULL;
# """

# # """
#  """
# ALTER TABLE author ADD COLUMN email VARCHAR(100) UNIQUE;

# """
#  """
#  ALTER TABLE Paper ADD COLUMN status VARCHAR(50) DEFAULT 'Pending Review';
# """
# """
# CREATE TABLE AdminLogin (
#     id INT AUTO_INCREMENT PRIMARY KEY,
#     username VARCHAR(64) NOT NULL UNIQUE,
#     password VARCHAR(128) NOT NULL
# );
# """
# """
# CREATE TABLE AuthorLogin (
#     id INT AUTO_INCREMENT PRIMARY KEY,
#     username VARCHAR(64) NOT NULL UNIQUE,
#     password VARCHAR(128) NOT NULL
# );

# CREATE TABLE ReviewerLogin (
#     id INT AUTO_INCREMENT PRIMARY KEY,
#     username VARCHAR(64) NOT NULL UNIQUE,
#     password VARCHAR(128) NOT NULL
# );

# """


# """
#  DROP TABLE contact;
#  """ 
       ]

        # Execute the SQL statements
        for sql in sql_statements:
            mycursor.execute(sql)

        conn.commit()
        print("Tables created successfully")

    except mysql.connector.Error as error:
        print(f"Error: {error}")

    finally:
        mycursor.close()
        conn.close()

if __name__ == "__main__":
    create_database_tables()



