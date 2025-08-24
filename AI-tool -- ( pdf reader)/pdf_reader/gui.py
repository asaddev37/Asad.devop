import tkinter as tk
from tkinter import ttk, filedialog, messagebox, font as tkfont
import threading
import os
import queue
import webbrowser
from datetime import datetime
from PIL import Image, ImageTk
from pdf_reader import PDFReaderAI

# Constants
PRIMARY_COLOR = "#2563eb"  # Blue-600
SECONDARY_COLOR = "#3b82f6"  # Blue-500
BG_COLOR = "#f8fafc"  # Slate-50
SIDEBAR_BG = "#ffffff"  # White
TEXT_COLOR = "#1e293b"  # Slate-800
TEXT_SECONDARY = "#64748b"  # Slate-500
ENTRY_BG = "#f1f5f9"  # Slate-100
BUTTON_HOVER = "#1d4ed8"  # Blue-700
CHAT_BG = "#ffffff"  # White
USER_MSG_BG = "#eff6ff"  # Blue-50
AI_MSG_BG = "#ffffff"  # White
BORDER_COLOR = "#e2e8f0"  # Slate-200
CHAT_INPUT_BG = "#f8fafc"  # Slate-50
SUGGESTION_BG = "#f1f5f9"  # Slate-100

class PDFReaderApp:
    def __init__(self, root):
        self.root = root
        self.root.title("PDF Reader AI")
        self.root.geometry("1000x700")
        self.root.configure(bg=BG_COLOR)
        self.root.minsize(800, 600)
        
        # Set application icon (if available)
        try:
            self.root.iconbitmap("icon.ico")
        except:
            pass
        
        # Initialize PDF reader
        self.pdf_reader = None
        self.current_file = ""
        self.model_name = "tinyllama:1.1b"  # Using tinyllama as it requires less memory
        
        # Queue for thread-safe GUI updates
        self.queue = queue.Queue()
        
        # Status variable
        self.status_var = tk.StringVar()
        self.status_var.set("Ready")
        
        # Custom fonts
        self.title_font = tkfont.Font(family="Segoe UI", size=18, weight="bold")
        self.subtitle_font = tkfont.Font(family="Segoe UI", size=12)
        self.button_font = tkfont.Font(family="Segoe UI", size=10, weight="bold")
        self.text_font = tkfont.Font(family="Segoe UI", size=10)
        self.chat_font = tkfont.Font(family="Segoe UI", size=11)
        
        # Track messages for UI updates
        self.messages = []
        
        # Configure styles
        self.setup_styles()
        
        # Setup UI
        self.setup_ui()
        self.check_queue()
        
    def setup_ui(self):
        """Set up the main user interface components"""
        # Configure grid weights
        self.root.grid_rowconfigure(1, weight=1)
        self.root.grid_columnconfigure(1, weight=1)
        
        # Setup header
        self.setup_header()
        
        # Setup sidebar
        self.setup_sidebar()
        
        # Setup status bar
        self.setup_status_bar()
        
        # Setup main content area
        self.setup_main_content()
        
        # Bind Enter key to send message
        self.root.bind('<Return>', self.on_enter_pressed)
    
    def setup_styles(self):
        style = ttk.Style()
        style.theme_use('clam')
        
        # Configure main window
        self.root.option_add('*Background', BG_COLOR)
        self.root.option_add('*Foreground', TEXT_COLOR)
        
        # Configure ttk styles
        style.configure('TFrame', background=BG_COLOR)
        style.configure('TLabel', background=BG_COLOR, foreground=TEXT_COLOR)
        
        # Modern button style
        style.configure('TButton', 
                       font=self.button_font,
                       padding=(15, 8),
                       relief='flat',
                       background=PRIMARY_COLOR,
                       foreground='white',
                       borderwidth=0)
        
        style.map('TButton',
                 background=[('active', BUTTON_HOVER), ('!disabled', PRIMARY_COLOR)],
                 foreground=[('active', 'white'), ('!disabled', 'white')],
                 relief=[('pressed', 'sunken'), ('!pressed', 'flat')])
        
        # Entry style
        style.configure('TEntry',
                      fieldbackground='white',
                      foreground=TEXT_COLOR,
                      insertcolor=TEXT_COLOR,
                      padding=10,
                      borderwidth=0,
                      relief='flat')
        
        # Scrollbar style
        style.layout('Vertical.TScrollbar',
                   [('Vertical.Scrollbar.trough',
                     {'children': [('Vertical.Scrollbar.thumb',
                                  {'expand': '1', 'sticky': 'nswe'})],
                      'sticky': 'ns'})])
        
        style.configure('Vertical.TScrollbar',
                       background=ENTRY_BG,
                       troughcolor=BG_COLOR,
                       arrowcolor=TEXT_COLOR,
                       bordercolor=BG_COLOR,
                       lightcolor=BG_COLOR,
                       darkcolor=BG_COLOR)
        
        # Configure label frame styles
        style.configure('TLabelframe', background=BG_COLOR, borderwidth=0)
        style.configure('TLabelframe.Label', background=BG_COLOR, foreground=TEXT_COLOR, font=self.subtitle_font)
    
    def setup_main_content(self):
        """Set up the main content area with chat interface"""
        # Main content area with subtle border
        main_frame = tk.Frame(self.root, bg='#f8fafc', bd=0)
        main_frame.grid(row=1, column=1, sticky='nsew', padx=0, pady=0)
        main_frame.grid_propagate(False)
        
        # Chat container with shadow effect - expanded to full width
        chat_container = tk.Frame(main_frame, bg='#f1f5f9')
        chat_container.pack(fill='both', expand=True, padx=0, pady=0)
        
        # Welcome message
        self.welcome_frame = tk.Frame(chat_container, bg='white', height=200)
        self.welcome_frame.pack(fill='both', expand=True, padx=40, pady=40)
        
        welcome_text = """# Welcome to PDF Reader AI
        
Upload a PDF document to get started. You can ask questions about the 
content and get AI-powered answers based on the document.

• Click 'Upload PDF' to select a document
• Click 'Load Document' to process it
• Start asking questions about the content"""
        
        welcome_label = tk.Label(
            self.welcome_frame,
            text=welcome_text,
            bg='white',
            fg='#334155',
            font=('Segoe UI', 11),
            justify='left',
            anchor='nw'
        )
        welcome_label.pack(fill='both', expand=True)
        
        # Chat display area (initially hidden)
        self.chat_display = tk.Frame(chat_container, bg='white')
        
        # Canvas and scrollbar for chat
        self.chat_canvas = tk.Canvas(
            self.chat_display, 
            bg='white', 
            highlightthickness=0
        )
        
        # Create scrollbar
        scrollbar = ttk.Scrollbar(
            self.chat_display,
            orient='vertical',
            command=self.chat_canvas.yview
        )
        
        # Create scrollable frame
        self.chat_scrollable_frame = ttk.Frame(self.chat_canvas)
        
        # Configure scrollbar style
        style = ttk.Style()
        style.configure('Custom.Vertical.TScrollbar',
                      background='#e2e8f0',
                      troughcolor='#f1f5f9',
                      arrowcolor=TEXT_COLOR,
                      bordercolor='#e2e8f0',
                      lightcolor='#e2e8f0',
                      darkcolor='#e2e8f0')
        
        # Configure canvas scrolling
        self.chat_scrollable_frame.bind(
            "<Configure>",
            lambda e: self.chat_canvas.configure(
                scrollregion=self.chat_canvas.bbox("all")
            )
        )
        
        # Add scrollable frame to canvas
        self.chat_canvas.create_window((0, 0), 
                                     window=self.chat_scrollable_frame, 
                                     anchor='nw', 
                                     width=self.root.winfo_width() - 350)  # Adjust for sidebar
        
        self.chat_canvas.configure(yscrollcommand=scrollbar.set)
        
        # Pack the canvas and scrollbar
        self.chat_canvas.pack(side='left', fill='both', expand=True)
        scrollbar.pack(side='right', fill='y')
        
        # Configure grid weights
        self.chat_display.columnconfigure(0, weight=1)
        self.chat_scrollable_frame.columnconfigure(0, weight=1)
        
        # Input area with card-like appearance
        input_container = tk.Frame(main_frame, bg='#f1f5f9', pady=8, padx=8)
        input_container.pack(fill='x', side='bottom', pady=(0, 8), padx=8)
        
        input_frame = tk.Frame(input_container, bg='white', bd=0, highlightthickness=1,
                             highlightbackground='#e2e8f0', highlightcolor='#3b82f6')
        input_frame.pack(fill='x', padx=0, pady=0)
        
        # Text input with placeholder
        self.input_text = tk.Text(
            input_frame,
            height=3,
            wrap=tk.WORD,
            font=('Segoe UI', 11),
            bd=0,
            padx=12,
            pady=10,
            highlightthickness=0
        )
        self.input_text.pack(fill='both', expand=True, padx=1, pady=1)
        self.input_text.bind('<Return>', self.on_enter_pressed)
        self.input_text.bind('<KeyRelease>', self.on_input_change)
        
        # Add placeholder text
        self.placeholder_text = "Type your question about the document..."
        self.input_text.insert('1.0', self.placeholder_text)
        self.input_text.config(fg='#94a3b8')
        self.input_text.bind('<FocusIn>', self.on_input_focus_in)
        self.input_text.bind('<FocusOut>', self.on_input_focus_out)
        
        # Button frame
        button_frame = tk.Frame(input_frame, bg='white', bd=0)
        button_frame.pack(fill='x', pady=(0, 4), padx=4)
        
        # Send button with icon
        self.send_button = tk.Button(
            button_frame,
            text="Send",
            command=self.process_question_input,
            bg=PRIMARY_COLOR,
            fg='white',
            font=('Segoe UI', 10, 'bold'),
            bd=0,
            padx=16,
            pady=6,
            cursor='hand2',
            relief='flat',
            activebackground='#1d4ed8',
            activeforeground='white'
        )
        self.send_button.pack(side='right')
        self.send_button.config(state=tk.DISABLED)
        
        # Create chat display area
        chat_display = tk.Frame(chat_container, bg='white')
        
        # Create canvas and scrollbar for chat
        chat_canvas = tk.Canvas(chat_display, bg='white', highlightthickness=0)
        scrollbar = ttk.Scrollbar(chat_display, orient='vertical', command=chat_canvas.yview)
        self.chat_scrollable_frame = ttk.Frame(chat_canvas)
        
        # Configure canvas scrolling
        self.chat_scrollable_frame.bind(
            "<Configure>",
            lambda e: chat_canvas.configure(
                scrollregion=chat_canvas.bbox("all")
            )
        )
        
        # Create window in canvas for the scrollable frame
        chat_canvas.create_window((0, 0), window=self.chat_scrollable_frame, anchor="nw")
        chat_canvas.configure(yscrollcommand=scrollbar.set)
        
        # Pack the scrollbar and canvas
        scrollbar.pack(side='right', fill='y')
        chat_canvas.pack(side='left', fill='both', expand=True)
        
        # Store references
        self.main_frame = main_frame
        self.chat_display = chat_display
        self.chat_canvas = chat_canvas
        
        # Configure grid weights
        self.root.grid_rowconfigure(1, weight=1)
        self.root.grid_columnconfigure(1, weight=1)
    
    def on_enter_pressed(self, event):
        """Handle Enter key press in the input field"""
        if event.state == 0 and event.keysym == 'Return' and not event.keysym == 'Shift_L':
            if event.state & 0x1:  # Shift+Enter for new line
                self.input_text.insert(tk.INSERT, '\n')
                return 'break'
            else:  # Just Enter to send
                self.process_question_input()
                return 'break'  # Prevent newline in the input field
                
    def on_input_focus_in(self, event):
        """Handle focus in event for input field"""
        current_text = self.input_text.get('1.0', 'end-1c').strip()
        if current_text == self.placeholder_text:
            self.input_text.delete('1.0', tk.END)
            self.input_text.config(fg='#1e293b')
    
    def on_input_focus_out(self, event):
        """Handle focus out event for input field"""
        current_text = self.input_text.get('1.0', 'end-1c').strip()
        if not current_text:
            self.input_text.insert('1.0', self.placeholder_text)
            self.input_text.config(fg='#94a3b8')
            
    def on_input_change(self, event=None):
        """Enable/disable send button based on input"""
        current_text = self.input_text.get('1.0', 'end-1c').strip()
        is_placeholder = (current_text == self.placeholder_text)
        
        if current_text and not is_placeholder and hasattr(self, 'send_button'):
            self.send_button.config(state=tk.NORMAL)
        elif hasattr(self, 'send_button'):
            self.send_button.config(state=tk.DISABLED)
            
    def process_question_input(self):
        """Process the question from the input field"""
        question = self.input_text.get('1.0', 'end-1c').strip()
        if question and question != self.placeholder_text:
            # Clear input
            self.input_text.delete('1.0', tk.END)
            self.send_button.config(state=tk.DISABLED)
            
            # Add user message to chat
            self.add_message("You", question, is_user=True)
            
            # Process question
            self.process_question(question)
            
    def setup_header(self):
        """Create the application header"""
        header = tk.Frame(
            self.root,
            bg=PRIMARY_COLOR,
            height=60,
            bd=0,
            highlightthickness=0
        )
        header.grid(row=0, column=0, columnspan=2, sticky='nsew')
        
        # App title
        title = tk.Label(
            header,
            text="PDF Reader AI",
            font=('Segoe UI', 18, 'bold'),
            fg='white',
            bg=PRIMARY_COLOR,
            padx=20
        )
        title.pack(side='left')
        
        # Add some padding
        tk.Frame(header, bg=PRIMARY_COLOR, width=20).pack(side='right')
        
        # Add a subtle shadow effect
        shadow = tk.Frame(self.root, height=2, bg='#cbd5e1')
        shadow.grid(row=0, column=0, columnspan=2, sticky='ew', pady=(60, 0))
    
    def setup_status_bar(self):
        """Create and configure the status bar"""
        # Create status bar frame
        self.status_bar = ttk.Frame(self.root, height=24, style='Status.TFrame')
        self.status_bar.grid(row=1, column=0, columnspan=2, sticky='ew')
        
        # Configure style for status bar
        style = ttk.Style()
        style.configure('Status.TFrame', background=BG_COLOR)
        
        # Status label
        status_label = ttk.Label(
            self.status_bar,
            textvariable=self.status_var,
            font=('Segoe UI', 8),
            background=BG_COLOR,
            foreground=TEXT_SECONDARY,
            anchor='w',
            padding=(10, 2, 10, 2)
        )
        status_label.pack(side='left', fill='x', expand=True)
        
        # Initially hide the status bar - it will be shown when needed
        self.status_bar.grid_remove()
    
    def new_chat(self):
        """Start a new chat session"""
        # Clear chat messages
        for widget in self.chat_scrollable_frame.winfo_children():
            widget.destroy()
        
        # Reset chat state
        self.messages = []
        
        # Show welcome message again
        if hasattr(self, 'welcome_frame'):
            self.chat_display.pack_forget()
            self.welcome_frame.pack(fill='both', expand=True, padx=40, pady=40)
        
        # Clear input
        self.input_text.delete('1.0', tk.END)
        self.input_text.insert('1.0', self.placeholder_text)
        self.input_text.config(fg='#94a3b8')
        self.send_button.config(state=tk.DISABLED)
        
        # Clear PDF preview if any
        if hasattr(self, 'preview_text'):
            self.preview_text.config(state='normal')
            self.preview_text.delete('1.0', tk.END)
            self.preview_text.insert('1.0', 'Load a PDF to see the preview here...')
            self.preview_text.config(state='disabled')
        
        # Reset file selection
        if hasattr(self, 'current_file'):
            self.current_file = ""
        if hasattr(self, 'file_name_var'):
            self.file_name_var.set("No file selected")
        if hasattr(self, 'load_btn'):
            self.load_btn.config(state=tk.DISABLED)
        
        self.update_status("New chat started")
    
    def setup_sidebar(self):
        # Sidebar frame with subtle shadow effect
        sidebar = tk.Frame(
            self.root,
            bg="#f8fafc",
            width=300,
            bd=0,
            highlightthickness=0
        )
        sidebar.grid(row=1, column=0, sticky='nsew', rowspan=2, padx=(0, 1))
        sidebar.grid_propagate(False)
        
        # Sidebar header with gradient effect
        header_frame = tk.Frame(sidebar, bg=PRIMARY_COLOR, height=60, bd=0)
        header_frame.pack(fill='x')
        
        # App title in sidebar
        title_label = tk.Label(
            header_frame,
            text="Document Viewer",
            font=('Segoe UI', 12, 'bold'),
            fg='white',
            bg=PRIMARY_COLOR,
            anchor='w',
            padx=20
        )
        title_label.pack(side='left', fill='x', expand=True)
        
        # New Chat button with icon
        new_chat_btn = tk.Button(
            header_frame,
            text=" New Chat",
            bg='#1e40af',
            fg='white',
            font=('Segoe UI', 9, 'bold'),
            bd=0,
            padx=12,
            pady=4,
            command=self.new_chat,
            cursor='hand2',
            relief='flat',
            compound='left'
        )
        new_chat_btn.pack(side='right', padx=10)
        
        # File upload section
        upload_section = tk.Frame(sidebar, bg='#f1f5f9', padx=16, pady=16)
        upload_section.pack(fill='x')
        
        # Upload button with icon
        upload_btn = tk.Button(
            upload_section,
            text="Upload PDF",
            bg='white',
            fg='#1e40af',
            font=('Segoe UI', 10),
            bd=1,
            relief='solid',
            padx=15,
            pady=8,
            command=self.browse_file,
            cursor='hand2'
        )
        upload_btn.pack(fill='x')
        
        # Selected file info
        file_info_frame = tk.Frame(upload_section, bg='#f1f5f9')
        file_info_frame.pack(fill='x', pady=(12, 0))
        
        self.file_name_var = tk.StringVar(value="No file selected")
        file_name_label = tk.Label(
            file_info_frame,
            textvariable=self.file_name_var,
            bg='#f1f5f9',
            fg='#475569',
            font=('Segoe UI', 9),
            anchor='w',
            wraplength=250
        )
        file_name_label.pack(fill='x')
        
        # Load Document button
        self.load_btn = tk.Button(
            upload_section,
            text="Load Document",
            bg='#1e40af',
            fg='white',
            font=('Segoe UI', 10, 'bold'),
            bd=0,
            padx=15,
            pady=8,
            command=self.load_pdf,
            cursor='hand2',
            state=tk.DISABLED
        )
        self.load_btn.pack(fill='x', pady=(12, 0))
        
        # Document preview section
        preview_frame = tk.Frame(sidebar, bg='white', padx=16, pady=16)
        preview_frame.pack(fill='both', expand=True, padx=1, pady=(0, 1))
        
        # Preview title
        preview_title = tk.Label(
            preview_frame,
            text="Document Preview",
            font=('Segoe UI', 10, 'bold'),
            fg='#1e293b',
            bg='white',
            anchor='w'
        )
        preview_title.pack(fill='x', pady=(0, 12))
        
        # Preview content
        self.preview_text = tk.Text(
            preview_frame,
            wrap=tk.WORD,
            bg='white',
            fg='#334155',
            font=('Segoe UI', 10),
            height=15,
            padx=8,
            pady=8,
            bd=0,
            highlightthickness=0
        )
        self.preview_text.pack(fill='both', expand=True)
        self.preview_text.insert('1.0', 'Load a PDF to see the preview here...')
        self.preview_text.config(state='disabled')
        
    def check_queue(self):
        try:
            while True:
                msg_type, *args = self.queue.get_nowait()
                if msg_type == "status":
                    self.status_var.set(args[0])
                    if hasattr(self, 'status_bar'):
                        self.status_bar.grid()
                        if hasattr(self, '_status_timer'):
                            self.root.after_cancel(self._status_timer)
                        self._status_timer = self.root.after(3000, self._hide_status_bar)
                elif msg_type == "message":
                    sender, message = args
                    self.add_message(sender, message)
                elif msg_type == "error":
                    self.show_error(args[0])
                    if hasattr(self, 'status_bar'):
                        self.status_bar.grid_remove()
        except queue.Empty:
            pass
        finally:
            self.root.after(100, self.check_queue)
    
    def update_status(self, message):
        if not hasattr(self, 'status_var') or not hasattr(self, 'status_bar'):
            return
            
        self.status_var.set(message)
        
        # Show the status bar
        self.status_bar.grid()
        
        # Schedule hiding the status bar after 3 seconds
        if hasattr(self, '_status_timer'):
            self.root.after_cancel(self._status_timer)
            
        self._status_timer = self.root.after(3000, self._hide_status_bar)
    
    def _hide_status_bar(self):
        """Hide the status bar"""
        if hasattr(self, 'status_bar'):
            self.status_bar.grid_remove()
    
    def add_message(self, sender, message, is_user=False):
        if not hasattr(self, 'messages'):
            self.messages = []
        self.messages.append((sender, message, is_user))
        
        # Make sure the chat display is visible
        if not hasattr(self, 'chat_display'):
            return
            
        # Hide welcome frame if it's visible
        if hasattr(self, 'welcome_frame') and self.welcome_frame.winfo_ismapped():
            self.welcome_frame.pack_forget()
            self.chat_display.pack(fill='both', expand=True)
        
        # Make sure the chat display is packed
        if not self.chat_display.winfo_ismapped():
            self.chat_display.pack(fill='both', expand=True)
        
        # Create and add message bubble
        if hasattr(self, 'chat_scrollable_frame'):
            bubble = self._create_message_bubble(self.chat_scrollable_frame, message, is_user)
            if bubble:
                bubble.pack(fill='x', pady=2, anchor='e' if is_user else 'w')
            
            # Update the canvas scroll region
            self.chat_scrollable_frame.update_idletasks()
            self.chat_canvas.configure(scrollregion=self.chat_canvas.bbox("all"))
            
            # Scroll to bottom
            self.chat_canvas.yview_moveto(1.0)
            
    def _create_message_bubble(self, parent, message, is_user=False):
        try:
            frame = ttk.Frame(parent, style='Message.TFrame')
            frame.pack(fill='x', pady=4)
            
            # Configure style based on sender
            if is_user:
                bg_color = USER_MSG_BG
                fg_color = TEXT_COLOR
                anchor = 'e'
                padx = (150, 20)  # Right-aligned with less right padding
            else:
                bg_color = AI_MSG_BG
                fg_color = TEXT_COLOR
                anchor = 'w'
                padx = (20, 150)  # Left-aligned with less left padding
                
            # Create message label with increased wraplength
            msg_label = tk.Label(
                frame,
                text=message,
                wraplength=600,  # Increased wraplength for wider messages
                justify='left',
                bg=bg_color,
                fg=fg_color,
                font=('Segoe UI', 10),
                padx=12,
                pady=8,
                relief='flat',
                anchor=anchor,
                bd=0
            )
            # Make message bubble expand to fill available width
            msg_label.pack(fill='x', padx=padx, pady=2)
            
            # Add timestamp
            timestamp = datetime.now().strftime("%H:%M")
            time_label = ttk.Label(
                frame,
                text=timestamp,
                font=('Segoe UI', 8),
                foreground='#94a3b8',
                background=bg_color
            )
            time_label.pack(side='bottom', anchor='e' if is_user else 'w', padx=padx, pady=(0, 5))
            
            return frame
            
        except Exception as e:
            print(f"Error creating message bubble: {e}")
            return None
    
    def show_error(self, error):
        messagebox.showerror("Error", error)
        self.update_status("Error occurred")
        
    def browse_file(self):
        """Open a file dialog to select a PDF file"""
        try:
            file_path = filedialog.askopenfilename(
                title="Select PDF File",
                filetypes=[("PDF Files", "*.pdf"), ("All Files", "*.*")]
            )
            
            if file_path:
                self.current_file = file_path
                file_name = os.path.basename(file_path)
                self.file_name_var.set(file_name[:30] + '...' if len(file_name) > 30 else file_name)
                self.update_status(f"Selected: {file_name}")
                
                # Enable the load button
                if hasattr(self, 'load_btn'):
                    self.load_btn.config(state=tk.NORMAL)
                
        except Exception as e:
            self.show_error(f"Error selecting file: {str(e)}")
            
    def load_pdf(self):
        """Load and process the selected PDF file"""
        if not hasattr(self, 'current_file') or not self.current_file:
            self.show_error("No file selected")
            return
            
        def process_pdf():
            try:
                import PyPDF2
                from PyPDF2 import PdfReader
                
                # Initialize PDF reader and extract text
                with open(self.current_file, 'rb') as file:
                    pdf_reader = PdfReader(file)
                    self.pdf_text = ""
                    preview_text = ""
                    
                    # Extract text from first few pages for preview
                    num_pages = len(pdf_reader.pages)
                    preview_pages = min(5, num_pages)  # Show first 5 pages in preview
                    
                    for i in range(preview_pages):
                        page_text = pdf_reader.pages[i].extract_text()
                        preview_text += f"--- Page {i+1} ---\n{page_text}\n\n"
                        self.pdf_text += page_text + "\n\n"
                    
                    # Add page count info
                    page_info = f"\n\n[Document contains {num_pages} pages in total]"
                    preview_text += page_info
                    
                    # Update preview in the UI
                    def update_preview():
                        self.preview_text.config(state='normal')
                        self.preview_text.delete('1.0', tk.END)
                        self.preview_text.insert('1.0', preview_text)
                        self.preview_text.config(state='disabled')
                        
                    self.root.after(0, update_preview)
                    
                    # Extract remaining pages in background
                    if num_pages > preview_pages:
                        for i in range(preview_pages, num_pages):
                            self.pdf_text += pdf_reader.pages[i].extract_text() + "\n\n"
                    
                    # Update UI on the main thread
                    self.root.after(0, self._finish_pdf_loading)
                    
            except Exception as e:
                error_msg = f"Error processing PDF: {str(e)}"
                self.root.after(0, lambda: self.show_error(error_msg))
                if hasattr(self, 'load_btn'):
                    self.root.after(0, lambda: self.load_btn.config(state=tk.NORMAL))
        
        try:
            self.update_status("Loading and processing PDF...")
            
            # Disable the load button during processing
            if hasattr(self, 'load_btn'):
                self.load_btn.config(state=tk.DISABLED)
            
            # Process PDF in a separate thread
            threading.Thread(target=process_pdf, daemon=True).start()
            
        except Exception as e:
            self.show_error(f"Error loading PDF: {str(e)}")
            if hasattr(self, 'load_btn'):
                self.load_btn.config(state=tk.NORMAL)
    
    def _finish_pdf_loading(self):
        """Finish up after PDF is loaded"""
        try:
            file_name = os.path.basename(self.current_file)
            self.update_status(f"Ready: {file_name}")
            
            # Enable chat input
            if hasattr(self, 'message_input'):
                self.message_input.config(state=tk.NORMAL)
                self.message_input.focus()
                
            # Add a welcome message
            welcome_msg = f"I've loaded '{file_name}'. Ask me anything about this document!"
            self.add_message("assistant", welcome_msg)
            
        except Exception as e:
            self.show_error(f"Error finalizing PDF load: {str(e)}")
        finally:
            if hasattr(self, 'load_btn'):
                self.load_btn.config(state=tk.NORMAL)
                
    def process_question(self, question):
        """Process the user's question using TinyLlama model"""
        try:
            if not hasattr(self, 'current_file') or not self.current_file:
                self.show_error("Please load a PDF file first")
                return
                
            # Show typing indicator
            self.queue.put(('status', 'Thinking...'))
            
            # Process the question in a separate thread to keep the UI responsive
            threading.Thread(
                target=self._process_question_async,
                args=(question,),
                daemon=True
            ).start()
            
        except Exception as e:
            self.show_error(f"Error processing question: {str(e)}")
            
    def _process_question_async(self, question):
        """Process the question asynchronously using TinyLlama"""
        try:
            import requests
            import json
            
            # Get PDF context (first 2000 chars to avoid context window issues)
            pdf_context = getattr(self, 'pdf_text', 'No PDF content available.')
            pdf_context = pdf_context[:2000]  # Limit context size
            
            # Prepare the prompt with context from the PDF
            prompt = f"""Please answer the question based on the following PDF content. If the answer cannot be found, say so.
            
PDF Content:
{pdf_context}

Question: {question}

Answer:"""
            
            # Call Ollama API with TinyLlama
            response = requests.post(
                'http://localhost:11434/api/generate',
                json={
                    'model': 'tinyllama:1.1b',
                    'prompt': prompt,
                    'stream': False
                }
            )
            
            if response.status_code == 200:
                result = response.json()
                answer = result.get('response', 'No response from model')
                self.root.after(0, lambda: self._send_response(answer))
            else:
                error_msg = f"Error from Ollama API: {response.text}"
                self.root.after(0, lambda: self.show_error(error_msg))
                
        except requests.exceptions.RequestException as e:
            error_msg = f"Failed to connect to Ollama. Make sure Ollama is running.\nError: {str(e)}"
            self.root.after(0, lambda: self.show_error(error_msg))
        except Exception as e:
            error_msg = f"Error processing question: {str(e)}"
            self.root.after(0, lambda: self.show_error(error_msg))
            
        except Exception as e:
            self.show_error(f"Error processing question: {str(e)}")
            
    def _send_response(self, response):
        """Send the AI response to the chat"""
        try:
            self.add_message("assistant", response)
            self.update_status("Ready")
        except Exception as e:
            self.show_error(f"Error sending response: {str(e)}")

def main():
    # Set DPI awareness for better text rendering on Windows
    try:
        from ctypes import windll
        windll.shcore.SetProcessDpiAwareness(1)
    except:
        pass
    
    root = tk.Tk()
    
    # Set window icon if available
    try:
        root.iconbitmap("icon.ico")
    except:
        pass
        
    # Configure window properties
    root.title("PDF Reader AI")
    root.geometry("1200x800")  # Larger default size
    root.minsize(1000, 700)  # Minimum size to ensure good layout
    
    # Set window size and position
    window_width = 1000
    window_height = 700
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    x = (screen_width // 2) - (window_width // 2)
    y = (screen_height // 2) - (window_height // 2)
    
    root.geometry(f'{window_width}x{window_height}+{x}+{y}')
    root.minsize(800, 600)
    root.configure(bg='#f8fafc')
    
    # Set application-wide styles
    style = ttk.Style()
    style.theme_use('clam')
    
    # Custom style for the send button
    style.configure('Send.TButton',
                   font=('Segoe UI', 12, 'bold'),
                   padding=(5, 5),
                   width=3,
                   background=PRIMARY_COLOR,
                   foreground='white',
                   borderwidth=0,
                   relief='flat')
    
    style.map('Send.TButton',
             background=[('active', BUTTON_HOVER)],
             foreground=[('active', 'white')])
    
    # Card style for chat area
    style.configure('Card.TFrame',
                   background='white',
                   relief='flat',
                   borderwidth=1,
                   bordercolor='#e2e8f0')
    
    # Input area style
    style.configure('Input.TFrame',
                   background=PRIMARY_COLOR,
                   relief='flat',
                   borderwidth=1,
                   bordercolor=PRIMARY_COLOR)
    
    # Initialize and run the application
    app = PDFReaderApp(root)
    
    # Add welcome message
    def show_welcome():
        app.add_message("AI", "Hello! I'm your PDF assistant. Please upload a PDF document to get started.")
    
    root.after(100, show_welcome)
    
    root.mainloop()

if __name__ == "__main__":
    main()
