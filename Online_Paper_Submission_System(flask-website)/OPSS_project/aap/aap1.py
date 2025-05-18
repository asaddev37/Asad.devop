# Import Libraries
from flask import Flask, render_template, request, redirect, flash, url_for, session
from datetime import datetime
from flask_sqlalchemy import SQLAlchemy
# from sqlalchemy import func
from sqlalchemy.exc import SQLAlchemyError
from datetime import datetime
from flask_bcrypt import Bcrypt
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required
from flask_login import current_user  # <-- Add this import at the top
# Rest of your code

from werkzeug.utils import secure_filename
import os
import mysql.connector
from datetime import datetime

app = Flask(__name__)
app.secret_key = "secret"

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+mysqlconnector://root:ak37@localhost/app1_database'


 # Initialize SQLAlchemy, Bcrypt, and LoginManager
db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'


# Models 

class AdminLogin(db.Model, UserMixin):
    __tablename__ = 'adminlogin'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), unique=True, nullable=False)
    password = db.Column(db.String(128), nullable=False)

    def __init__(self, username, password):
        self.username = username
        self.password = bcrypt.generate_password_hash(password).decode('utf-8')

    def check_password(self, password):
        return bcrypt.check_password_hash(self.password, password)

    def get_id(self):
        return f"admin_{self.id}"  # Prefix with role


class AuthorLogin(db.Model, UserMixin):
    __tablename__ = 'authorlogin'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), unique=True, nullable=False)
    password = db.Column(db.String(128), nullable=False)

    def __init__(self, username, password):
        self.username = username
        self.password = bcrypt.generate_password_hash(password).decode('utf-8')

    def check_password(self, password):
        return bcrypt.check_password_hash(self.password, password)

    def get_id(self):
        return f"author_{self.id}"  # Prefix with role


class ReviewerLogin(db.Model, UserMixin):
    __tablename__ = 'reviewerlogin'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), unique=True, nullable=False)
    password = db.Column(db.String(128), nullable=False)

    def __init__(self, username, password):
        self.username = username
        self.password = bcrypt.generate_password_hash(password).decode('utf-8')

    def check_password(self, password):
        return bcrypt.check_password_hash(self.password, password)

    def get_id(self):
        return f"reviewer_{self.id}"  # Prefix with role


# <----------------------------------------------------------------------------------------------->
# Models

class Author(db.Model):
    __tablename__ ='author' 
    Author_ID= db.Column('Author_ID', db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    affiliation = db.Column(db.String(200))
    tel_no = db.Column(db.String(15))
    email = db.Column(db.String(100), unique=True)
    postal_address = db.Column(db.String(300))
    # Define relationship to Paper
    papers = db.relationship('Paper', backref='author', lazy=True)
   
class Paper(db.Model):
    __tablename__ = 'paper'
    id = db.Column('Paper_ID', db.Integer, primary_key=True)
    title = db.Column(db.String(200))
    abstract = db.Column(db.Text)
    keywords = db.Column(db.String(200))
    paper_type = db.Column(db.String(50))
    submission_date = db.Column(db.Date)
    file_name = db.Column(db.String(200))
    status = db.Column(db.String(50), default="Pending Review")
    author_id = db.Column(db.Integer, db.ForeignKey('author.Author_ID'), nullable=False)
    access_pin = db.Column(db.String(5), nullable=False , unique=True)  # New PIN field

class Reviewer(db.Model):
    __tablename__ = 'reviewer'  # Explicitly define the table name
    Reviewer_ID = db.Column('Reviewer_ID', db.Integer, primary_key=True)  # Corrected primary key
    name = db.Column('Name', db.String(255))  # Map 'name' to 'Name'
    specialization = db.Column('Specialization', db.String(255))  # Map 'specialization' to 'Specialization'
    max_papers = db.Column('Max_Papers', db.Integer)  # Map 'max_papers' to 'Max_Papers'
    email = db.Column('Email', db.String(255), unique=True)  # Map 'email' to 'Email'
    pin = db.Column('Pin', db.String(5), nullable=False , unique=True)  # Add PIN field


class Assignment(db.Model):
    __tablename__ = 'assignments'
    id = db.Column(db.Integer, primary_key=True)
    paper_id = db.Column(db.Integer, db.ForeignKey('paper.Paper_ID'), nullable=False)
    reviewer_id = db.Column(db.Integer, db.ForeignKey('reviewer.Reviewer_ID'), nullable=False)
    assigned_at = db.Column(db.DateTime, default=db.func.current_timestamp())
    paper = db.relationship('Paper', backref='assignments', lazy=True)  
    reviewer = db.relationship('Reviewer', backref='assignments', lazy=True)

class Review(db.Model):
    __tablename__ = 'reviews'  # Explicit table name to avoid ambiguities
    id = db.Column(db.Integer, primary_key=True)  # Renamed for consistency
    assignment_id = db.Column(db.Integer, db.ForeignKey('assignments.id'), nullable=False)
    paper_id = db.Column(db.Integer, db.ForeignKey('paper.Paper_ID'), nullable=False)  # ForeignKey to Paper
    reviewer_id = db.Column(db.Integer, db.ForeignKey('reviewer.Reviewer_ID'), nullable=False)  # ForeignKey to Reviewer
    quality_score = db.Column(db.Integer)
    comments = db.Column(db.Text)
    submitted_at = db.Column(db.DateTime, default=datetime.utcnow)  # Timestamp with default

    # Relationships
    paper = db.relationship('Paper', lazy=True)  # No backref; links Review to Paper
    reviewer = db.relationship('Reviewer', backref='review_list', lazy=True)  # New, unique backref for Reviewer
    assignment = db.relationship('Assignment', backref='review_details', lazy=True)  # New, unique backref for Assignment


class ConferenceDetails(db.Model):
    __tablename__ = 'ConferenceDetails'
    id = db.Column(db.Integer, primary_key=True)
    paper_id = db.Column(db.Integer, db.ForeignKey('paper.Paper_ID'), nullable=False)
    presentation_time = db.Column(db.DateTime, nullable=False)
    location = db.Column(db.String(255), nullable=False)
      # Define relationships
    paper = db.relationship('Paper', backref='ConferenceDetails', lazy=True)

class Contact(db.Model):
    __tablename__ = 'Contact'
    id = db.Column('Contact_ID', db.Integer, primary_key=True)
    name = db.Column(db.String(200))
    email = db.Column(db.String(200), unique=True)
    message = db.Column(db.Text)

    def __init__(self, name, email, message):
        self.name = name
        self.email = email
        self.message = message


# <------------------------------------------------------------------------------------------------------------------>
# Routes 

@app.route('/')
def choose_role():
    return render_template('choose_role.html')

@login_manager.user_loader
def load_user(user_id):
    try:
        role, user_id = user_id.split('_')  # Unpack role and user ID
        user_id = int(user_id)  # Ensure the user ID is an integer

        if role == 'admin':
            return AdminLogin.query.get(user_id)
        elif role == 'author':
            return AuthorLogin.query.get(user_id)
        elif role == 'reviewer':
            return ReviewerLogin.query.get(user_id)
        return None
    except ValueError:
        return None  # Handle invalid user_id format

@app.route('/login/<role>', methods=['GET', 'POST'])
def login(role):
    error_message = None
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        if role == 'admin':
            user_model = AdminLogin
        elif role == 'author':
            user_model = AuthorLogin
        elif role == 'reviewer':
            user_model = ReviewerLogin
        else:
            return "Invalid role", 400

        user = user_model.query.filter_by(username=username).first()
        if user and user.check_password(password):
            login_user(user)  # `get_id()` automatically prefixes the role
            if role == 'admin':
                return redirect(url_for('home2'))
            elif role == 'author':
                return redirect(url_for('home1'))
            elif role == 'reviewer':
                return redirect(url_for('home3'))
        else:
            error_message = "Invalid username or password. Please try again."
    
    return render_template('login.html', role=role, error_message=error_message)



# Sign-Up Routes
@app.route('/signup/<role>', methods=['GET', 'POST'])
def signup(role):
    if request.method == 'GET':
        return render_template('signup.html', role=role)
    elif request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        if role == 'admin':
            new_user = AdminLogin(username=username, password=password)
        elif role == 'author':
            new_user = AuthorLogin(username=username, password=password)
        elif role == 'reviewer':
            new_user = ReviewerLogin(username=username, password=password)
        else:
            return "Invalid Role", 400

        db.session.add(new_user)
        db.session.commit()
    return render_template('login.html', role=role, )
    
@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash("You have been logged out.", "success")
    return redirect(url_for('choose_role'))

 # <-------------------------------------------------------------------------------------------------------------------->

@app.route('/home1')
@login_required
def home1():
    if not isinstance(current_user, AuthorLogin):
        flash("Access denied.", "error")
        return redirect('/')
    return render_template('home1.html')

@app.route('/home2')
@login_required
def home2():
    if not isinstance(current_user, AdminLogin):
        flash("Access denied.", "error")
        return redirect('/')
    return render_template('home2.html')

@app.route('/home3')
@login_required
def home3():
    if not isinstance(current_user, ReviewerLogin):
        flash("Access denied.", "error")
        return redirect('/')
    return render_template('home3.html')

# <-------------------------------------------------------------------------------------------------------------->

app.config['UPLOAD_FOLDER'] = 'static\media'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
ALLOWED_EXTENSIONS = {'pdf', 'docx', 'png', 'jpeg', 'jpg'}

   # Ensure Upload Folder Exists
if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])
# Define Allowed File Extensions
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Paper Upload Route
@app.route('/paper-upload', methods=['GET', 'POST'])
def paper_upload():
    if request.method == 'POST':
        try:
            # Retrieve form data
            access_pin = request.form.get('access_pin', '').strip()
            if not access_pin or len(access_pin) != 5 or not access_pin.isdigit():
                flash("Please enter a valid 5-digit PIN.", "error")
                return redirect(request.url)

            # Check if the access pin already exists in the database
            existing_author = Author.query.filter_by(Author_ID=access_pin).first()
            if existing_author:
                flash("This PIN is already in use. Please use a unique PIN for new author registration.", "error")
                return redirect(request.url)

            # Retrieve author details
            author_name = request.form.get('author_name', '').strip()
            author_affiliation = request.form.get('author_affiliation', '').strip()
            author_tel_no = request.form.get('author_tel_no', '').strip()
            author_email_address = request.form.get('author_email_address', '').strip()
            author_postal_address = request.form.get('author_postal_address', '').strip()

            # Retrieve paper details
            paper_title = request.form.get('paper_title', '').strip()
            paper_abstract = request.form.get('paper_abstract', '').strip()
            paper_keywords = request.form.get('paper_keywords', '').strip()
            paper_type = request.form.get('paper_type', '').strip()
            paper_submission_date = request.form.get('paper_submission_date', '').strip()
            paper_file = request.files.get('paper_file')

            # Validate that all fields are filled
            if not all([
                author_name,
                author_affiliation,
                author_tel_no,
                author_email_address,
                author_postal_address,
                paper_title,
                paper_abstract,
                paper_keywords,
                paper_type,
                paper_submission_date,
                paper_file
            ]):
                flash("Please fill all required fields. All fields are mandatory.", "error")
                return redirect(request.url)

            # Validate the file type
            if paper_file and allowed_file(paper_file.filename):
                filename = secure_filename(paper_file.filename)
                file_path = os.path.join(app.root_path, app.config['UPLOAD_FOLDER'], filename)
                paper_file.save(file_path)
            else:
                flash("Invalid file type. Only PDF and DOCX are allowed.", "error")
                return redirect(request.url)

            # Save the author information in the database
            new_author = Author(
                Author_ID=access_pin,
                name=author_name,
                affiliation=author_affiliation,
                tel_no=author_tel_no,
                email=author_email_address,
                postal_address=author_postal_address
            )
            db.session.add(new_author)

            # Save the paper information and link it to the author
            new_paper = Paper(
                title=paper_title,
                abstract=paper_abstract,
                keywords=paper_keywords,
                paper_type=paper_type,
                submission_date=paper_submission_date,
                file_name=filename,
                access_pin=access_pin,  # Associate with the given PIN
                author_id=new_author.Author_ID  # Link to the newly created author
            )
            db.session.add(new_paper)
            db.session.commit()

            flash("Author and Paper successfully submitted!", "success")
            return redirect('/choose-user-type')

        except Exception as e:
            print(f"Error: {e}")
            flash("An error occurred while processing your submission.", "error")
            return render_template('error.html')

    return render_template('paper-upload.html')


@app.route('/paper-upload1', methods=['GET', 'POST'])
def paper_upload1():
    if request.method == 'POST':
        try:
            # Retrieve the access PIN from the session
            access_pin = session.get('access_pin')
            print(f"Access PIN from session: {access_pin}")  # Debugging

            if not access_pin:
                flash("Access PIN is missing in session. Please re-enter your PIN.", "error")
                return redirect('/enter-pin1')

            # Retrieve the author associated with the access PIN
            author = Author.query.filter_by(Author_ID=int(access_pin)).first()  # Convert PIN to integer
            print(f"Author retrieved: {author}")  # Debugging

            if not author:
                flash("Invalid access PIN. No author found with this PIN.", "error")
                return redirect('/enter-pin1')

            # Retrieve form data
            paper_title = request.form.get('paper_title', '').strip()
            paper_abstract = request.form.get('paper_abstract', '').strip()
            paper_keywords = request.form.get('paper_keywords', '').strip()
            paper_type = request.form.get('paper_type', '').strip()
            paper_submission_date = request.form.get('paper_submission_date', '').strip()
            paper_file = request.files.get('paper_file')

            # Check for missing fields
            if not all([paper_title, paper_abstract, paper_keywords, paper_type, paper_submission_date, paper_file]):
                flash("Please fill all required fields. All fields are mandatory.", "error")
                return redirect(request.url)

            # Validate file type
            if paper_file and allowed_file(paper_file.filename):
                filename = secure_filename(paper_file.filename)
                file_path = os.path.join(app.root_path, app.config['UPLOAD_FOLDER'], filename)
                paper_file.save(file_path)
            else:
                flash("Invalid file type. Only PDF and DOCX are allowed.", "error")
                return redirect(request.url)

            # Save paper info in the database
            new_paper = Paper(
                title=paper_title,
                abstract=paper_abstract,
                keywords=paper_keywords,
                paper_type=paper_type,
                submission_date=paper_submission_date,
                file_name=filename,
                access_pin=access_pin,  # Use the same access PIN to allow multiple papers
                author_id=author.Author_ID  # Associate paper with the correct author
            )
            db.session.add(new_paper)
            db.session.commit()

            flash("Paper successfully submitted!", "success")
            return redirect('/paper-upload1')  # Redirect back to paper upload page for additional submissions

        except Exception as e:
            print(f"Error: {e}")  # Log the error for debugging
            flash("An error occurred while processing your submission.", "error")
            return render_template('error.html')

    return render_template('paper-upload1.html')



@app.route('/choose-user-type', methods=['GET', 'POST'])
def choose_user_type():
    if request.method == 'POST':
        user_type = request.form.get('user_type')

        # Redirect based on user type
        if user_type == 'regular':
            return redirect('/enter-pin1')
        elif user_type == 'new':
            return redirect('/paper-upload')
        else:
            flash("Invalid user type selection.", "error")
            return redirect('/choose-user-type')

    return render_template('choose-user-type.html')
@app.route('/enter-pin1', methods=['GET', 'POST'])
def enter_pin1():
    if request.method == 'POST':
        access_pin = request.form.get('access_pin', '').strip()
        print(f"Access PIN entered: {access_pin}")  # Debugging

        if not access_pin or len(access_pin) != 5 or not access_pin.isdigit():
            flash("Please enter a valid 5-digit PIN.", "error")
            return redirect(request.url)

        # Validate if the access PIN exists in the Author table
        author = Author.query.filter_by(Author_ID=int(access_pin)).first()  # Convert to integer
        print(f"Author found with PIN: {author}")  # Debugging

        if not author:
            flash("Invalid PIN. No author found with this PIN.", "error")
            return redirect(request.url)

        # Save the valid access PIN in the session
        session['access_pin'] = access_pin
        flash("Access PIN verified. You can now upload papers.", "success")
        return redirect('/paper-upload1')

    return render_template('enter-pin1.html')



# View Papers Route
@app.route('/view-papers', methods=["GET", "POST"])
@login_required
def view_paper_by_pin():
    if request.method == "POST":
        # Get Access PIN from the form
        access_pin = request.form.get("access_pin", "").strip()
        print(f"Access PIN entered: {access_pin}")  # Debugging: Log the PIN entered

        # Connect to the database
        mydb = mysql.connector.connect(
            host="localhost",
            user="root",
            password="ak37",
            database="app1_database"
        )
        mycursor = mydb.cursor(dictionary=True)

        # Query to fetch all papers associated with the provided Access PIN
        sql = """
        SELECT Paper.Paper_ID, Paper.Title, Paper.Abstract, Paper.Keywords, Paper.Paper_Type, 
               Paper.Submission_Date, Paper.File_Name, Paper.Status, Paper.Author_ID, 
               Paper.Access_Pin, Author.Name AS Author_Name
        FROM Paper
        JOIN Author ON Paper.Author_ID = Author.Author_ID
        WHERE Paper.Access_Pin = %s
        """
        
        # Execute the query
        print(f"Executing SQL with PIN: {access_pin}")  # Debugging: Check the PIN used in query
        mycursor.execute(sql, (access_pin,))
        papers = mycursor.fetchall()

        # Debugging: Log the number of papers found
        print(f"Number of papers found: {len(papers)}")
        
        # If papers are found, render them on the page
        if papers:
            return render_template("view-papers.html", papers=papers)
        else:
            # No papers found, show an error message
            print("Invalid PIN or no papers found.")
            flash("Invalid PIN or no papers found.", "error")
            return redirect(request.url)

    # GET Request: Show the PIN entry form
    return render_template("enter-pin.html")



# view_conference_details route
@app.route('/view_conference_details')
@login_required
def view_conference_detail():
    # Query to fetch conference details
    conference_details = db.session.query(
        Paper.id.label('paper_id'),
        Paper.title.label('paper_title'),
        Author.name.label('author_name'),
        ConferenceDetails.presentation_time.label('presentation_time'),
       ConferenceDetails.location.label('location'),
       ConferenceDetails.id.label('conference_id')
    ).join(Author, Paper.author_id == Author.Author_ID)\
     .join(ConferenceDetails, Paper.id == ConferenceDetails.paper_id)\
     .all()

    # Render the template with conference details
    return render_template('view_conference_details.html', conference_details=conference_details)


  # contact Route  
@app.route('/contact', methods=['GET', 'POST'])
def contact():
    if request.method == 'POST':
        # Retrieve form data
        name = request.form.get('name')
        email = request.form.get('email')
        message = request.form.get('message')       
        # Validate input fields
        if not name or not email or not message:
            flash("All fields are required. Please fill out the form completely.", "danger")
            return render_template('contact.html', name=name, email=email, message=message)       
        # Add the contact message to the database
        new_contact = Contact(name=name, email=email, message=message)
        db.session.add(new_contact)
        db.session.commit()       
        flash("Message sent successfully!", "success")
        return redirect(url_for('home1'))   
    return render_template('contact.html')



# <------------------------------------------------------------------------------------------------------------------>

# View Papers Route
@app.route('/view-papers2')
@login_required
def view_papers2():  
    try:
        mydb = mysql.connector.connect(
            host='localhost',
            user='root',
            password='ak37',
            database='app1_database'
        )
        mycursor = mydb.cursor()       
        sql = "SELECT * FROM Paper"
        mycursor.execute(sql)
        papers = mycursor.fetchall()
        new_papers = []
        for paper in papers:
            paper = list(paper)
            paper[6] = paper[6].replace('\\', '/')
            print(paper[6])
            new_papers.append(paper)
        print(new_papers)       

        return render_template('view-papers2.html', papers=new_papers)
    except Exception as e:
        print(f"Error: {e}")
        flash("An error occurred while processing your request.")
        return redirect('/')
    
# view reviewers route 
@app.route('/existing-reviewers')
def reviewers_list():
    try:
        # Fetch all reviewers from the database
        reviewers = Reviewer.query.all()
        
        # Pass the reviewers to the template
        return render_template('existing-reviewers.html', reviewers=reviewers)
    except Exception as e:
        print(f"Error fetching reviewers: {e}")
        flash("An error occurred while fetching reviewers.", "error")
        return render_template('error.html')  # Optional error page



# assignment Route
@app.route("/assignment", methods=["GET", "POST"])
@login_required
def assignment():
    if request.method == "POST":
        # Get form data   
        paper_id = request.form.get("Paper_ID")
        reviewer_id = request.form.get("Reviewer_ID")
        
        # Validate inputs
        if not paper_id or not reviewer_id:
            flash("Both Paper and Reviewer are required to assign!", "error")
            return redirect(url_for("assignment"))
        try:
            paper_id = int(paper_id)
            reviewer_id = int(reviewer_id)
        except ValueError:
            flash("Invalid Paper or Reviewer ID!", "error")
            return redirect(url_for("assignment"))
        
        # Fetch paper and reviewer
        paper = Paper.query.get(paper_id)
        reviewer = Reviewer.query.get(reviewer_id)
        if not paper:
            flash("Paper not found!", "error")
            return redirect(url_for("assignment"))       
        if not reviewer:
            flash("Reviewer not found!", "error")
            return redirect(url_for("assignment"))
        
        # Check if the reviewer has exceeded their maximum paper limit
        current_assignments = Assignment.query.filter_by(reviewer_id=reviewer_id).count()
        if current_assignments >= reviewer.max_papers:
            flash(f"Reviewer '{reviewer.name}' has reached their maximum paper limit!", "error")
            return redirect(url_for("assignment"))
        
        # Check if the paper has already been assigned to two reviewers
        paper_assignments = Assignment.query.filter_by(paper_id=paper_id).count()
        if paper_assignments >= 2:
            flash(f"Paper '{paper.title}' has already been assigned to the maximum of two reviewers.", "error")
            return redirect(url_for("assignment"))
        
        # Check if the paper is already assigned to the selected reviewer
        existing_assignment = Assignment.query.filter_by(paper_id=paper_id, reviewer_id=reviewer_id).first()
        if existing_assignment:
            flash("This paper is already assigned to the selected reviewer.", "error")
            return redirect(url_for("assignment"))
        
        # Create a new assignment
        new_assignment = Assignment(paper_id=paper_id, reviewer_id=reviewer_id)
        db.session.add(new_assignment)
        db.session.commit()  # Save the assignment to the database
        flash(f"Paper '{paper.title}' has been successfully assigned to Reviewer '{reviewer.name}'.", "success")
        return redirect(url_for("assignment"))
    
    # Fetch papers and reviewers for the dropdown menus
    papers = Paper.query.filter(Paper.status == "Pending Review").all()
    reviewers = Reviewer.query.all()
    
    # Fetch assignments with joined paper, reviewer, and author details
    assignments = db.session.query(
        Assignment,
        Paper.title.label("paper_title"),
        Paper.keywords.label("keywords"),
        Paper.paper_type.label("paper_type"),
        Paper.submission_date.label("submission_date"),
        Reviewer.name.label("reviewer_name"),
        Reviewer.specialization.label("reviewer_specialization"),
        Reviewer.max_papers.label("max_papers"),
        Author.name.label("author_name"),
    ).join(
        Paper, Assignment.paper_id == Paper.id
    ).join(
        Reviewer, Assignment.reviewer_id == Reviewer.Reviewer_ID
    ).join(Author, Paper.author_id == Author.Author_ID).all()
    
    return render_template(
        "assignment.html",
        papers=papers,
        reviewers=reviewers,
        assignments=assignments
    )

# view review route
@app.route('/view-reviews')
@login_required
def view_reviews():
    # Fetch all reviews, join with related tables for additional details
 reviews = db.session.query(
    Review.id.label('review_id'),
    Review.assignment_id.label('assignment_id'),  # Fetch assignment_id
    Review.paper_id.label('paper_id'),
    Paper.title.label('paper_title'),
    Review.reviewer_id.label('reviewer_id'),
    Reviewer.name.label('reviewer_name'),
    Review.quality_score.label('quality_score'),
    Review.comments.label('comments'),
    Review.submitted_at.label('submitted_at')
).join(Paper, Review.paper_id == Paper.id)\
 .join(Reviewer, Review.reviewer_id == Reviewer.Reviewer_ID)\
 .outerjoin(Assignment, Review.assignment_id == Assignment.id)\
 .all()


    # Render the HTML template and pass the fetched reviews
 return render_template('view-reviews.html', reviews=reviews)


#conference details route
@app.route("/conference_details", methods=["GET", "POST"])
@login_required
def conference_details():
    if request.method == "POST":
        # Fetch form data
        paper_id = request.form.get("paper_id_conference")
        presentation_time = request.form.get("presentation_time")
        location = request.form.get("location")
        # Validate input
        if not paper_id or not presentation_time or not location:
            flash("All fields are required. Please fill in all the details.", "error")
            return redirect(url_for("conference_details"))
        # Check if the paper exists
        paper = Paper.query.get(int(paper_id))  # Convert paper_id to integer
        if not paper:
            flash("Paper ID does not exist. Please provide a valid Paper ID.", "error")
            return redirect(url_for("conference_details"))
        # Create new conference detail
        try:
            # Use datetime.fromisoformat to handle ISO 8601 format
            parsed_time = datetime.fromisoformat(presentation_time)
            new_conference_detail = ConferenceDetails(
                paper_id=int(paper_id),  # Convert paper_id to integer
                presentation_time=parsed_time,
                location=location
            )
            db.session.add(new_conference_detail)
            db.session.commit()
            flash("Conference details added successfully!", "success")
        except ValueError as e:
            flash(f"Invalid date/time format: {str(e)}", "error")
        except Exception as e:
            db.session.rollback()
            flash(f"An error occurred: {str(e)}", "error")
        return redirect(url_for("conference_details"))
    return render_template("conference_details.html")

# View_contact route 
@app.route('/view_contacts')
@login_required
def view_contacts():
    # Query all contact records
    contacts = Contact.query.all()
    # Render the HTML template with the contacts data
    return render_template('view_contacts.html', contacts=contacts)

# <---------------------------------------------------------------------------------------------------------------------------->

# Reviewer Route
@app.route("/reviewer", methods=["GET", "POST"])
@login_required
def reviewer():
    if request.method == "POST":
        # Retrieve form data
        reviewer_name = request.form.get("reviewer_name")
        reviewer_specialization = request.form.get("reviewer_specialization")
        reviewer_max_papers = request.form.get("reviewer_max_papers", type=int)
        reviewer_email = request.form.get("reviewer_email")
        reviewer_pin = request.form.get("reviewer_pin")
        
        # Validate input
        if not reviewer_name or not reviewer_specialization or not reviewer_max_papers or not reviewer_email or not reviewer_pin:
            flash("Please fill in all required fields.", "error")
            return redirect(url_for("reviewer"))
        if len(reviewer_pin) != 5 or not reviewer_pin.isdigit():
            flash("PIN must be a 5-digit number.", "error")
            return redirect(url_for("reviewer"))

        # Create and save the new reviewer
        new_reviewer = Reviewer(
            name=reviewer_name,
            specialization=reviewer_specialization,
            max_papers=reviewer_max_papers,
            email=reviewer_email,
            pin=reviewer_pin
        )
        db.session.add(new_reviewer)
        db.session.commit()
        flash("Reviewer added successfully!", "success")
        return redirect(url_for("reviewer"))

    # For GET request, fetch existing reviewers to display
    reviewers = Reviewer.query.all()
    return render_template("reviewer.html", reviewers=reviewers)


# view_assignments route
@app.route('/view-assignments', methods=["GET", "POST"])
@login_required
def view_assignments():
    if request.method == "POST":
        # Get reviewer PIN from the form
        reviewer_pin = request.form.get("reviewer_pin")

        # Find the reviewer with the provided PIN
        reviewer = Reviewer.query.filter_by(pin=reviewer_pin).first()
        if not reviewer:
            flash("Invalid PIN. Please try again.", "error")
            return redirect(url_for("view_assignments"))

        # Fetch assignments for this reviewer
        assignments = Assignment.query.filter_by(reviewer_id=reviewer.Reviewer_ID).join(Assignment.paper).all()

        return render_template('view-assignments.html', assignments=assignments)

    return render_template('verify_pin.html', action="view-assignments")


# View Papers Route
@app.route('/view-papers3', methods=["GET", "POST"])
@login_required
def view_papers3():
    if request.method == "POST":
        print("hello")
        # Get reviewer PIN from the form
        reviewer_pin = request.form.get("reviewer_pin")

        # Find the reviewer with the provided PIN
        reviewer = Reviewer.query.filter_by(pin=reviewer_pin).first()
        if not reviewer:
            flash("Invalid PIN. Please try again.", "error")
            return redirect(url_for("view_papers3"))

        # Fetch papers assigned to this reviewer
        papers = Paper.query.join(Assignment).filter(Assignment.reviewer_id == reviewer.Reviewer_ID).all()
        print(papers[0])

        return render_template('view-papers3.html', papers=papers)

    
    return render_template('verify_pin2.html', action="view-papers3")


# submit review route
@app.route("/submit-review", methods=["GET", "POST"])
@login_required
def review():
    if request.method == "POST":
        # Get form data
        paper_id = request.form.get('paper_id', '').strip()
        reviewer_id = request.form.get('reviewer_id', '').strip()
        quality_score = request.form.get('quality_score', '').strip()
        comments = request.form.get('comments', '').strip()
        # Validate input
        if not paper_id or not reviewer_id or not quality_score or not comments:
            flash("Paper ID, Reviewer ID,  Quality Score and Comments are required.", "error")
            return redirect(url_for("review"))
        try:
            # Query the database for the specific review
            review = Review.query.filter_by(paper_id=paper_id, reviewer_id=reviewer_id).first()
            if not review:
                # Create new review if not found
                review = Review(paper_id=paper_id, reviewer_id=reviewer_id)
            # Update review details
            review.quality_score = int(quality_score)
            review.comments = comments
            review.submitted_at = datetime.utcnow()  # Update submission time
            # Commit the changes
            db.session.add(review)  # Add review to session
            db.session.commit()
            flash("Review submitted successfully!", "success")
            return redirect(url_for("home3"))
        except SQLAlchemyError as e:
            # Handle any database errors
            db.session.rollback()
            flash(f"An error occurred: {str(e)}", "error")
            return redirect(url_for("review"))
    # Render the review submission form
    return render_template("submit-review.html")


@app.route('/contact3', methods=['GET', 'POST'])
def contact3():
    if request.method == 'POST':
        # Retrieve form data
        name = request.form.get('name')
        email = request.form.get('email')
        message = request.form.get('message')       
        # Validate input fields
        if not name or not email or not message:
            flash("All fields are required. Please fill out the form completely.", "danger")
            return render_template('contact3.html', name=name, email=email, message=message)       
        # Add the contact message to the database
        new_contact = Contact(name=name, email=email, message=message)
        db.session.add(new_contact)
        db.session.commit()       
        flash("Message sent successfully!", "success")
        return redirect(url_for('home3'))   
    return render_template('contact3.html')








if __name__ == "__main__":
    app.run(debug=True)
