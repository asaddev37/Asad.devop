@app.route('/paper-upload1', methods=['GET', 'POST'])
def paper_upload1():  # Make the function name match the route
    
    if request.method == 'POST':
        try:
            # Retrieve the access pin from the session
            access_pin = session.get('access_pin')
            if not access_pin:
                flash("Access PIN is missing in session.", "error")
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
            paper = Paper.query.filter_by(access_pin=access_pin).first()
            if not paper:
                flash("No paper found with this Access PIN.", "error")
                return redirect('/enter-pin1')

            # Update existing paper entry with new submission
            paper.title = paper_title
            paper.abstract = paper_abstract
            paper.keywords = paper_keywords
            paper.paper_type = paper_type
            paper.submission_date = paper_submission_date
            paper.file_name = filename

            db.session.commit()

            flash("Paper successfully submitted!", "success")
            return redirect('/choose_user_type')  # Redirect to a success page

        except Exception as e:
            print(f"Error: {e}")
            flash("An error occurred while processing your submission.", "error")
            return render_template('error.html')

    return render_template('paper-upload1.html')

