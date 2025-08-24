import os
import re
import argparse
from typing import List, Dict, Optional
import pdfplumber
import ollama
from dotenv import load_dotenv

class PDFReaderAI:
    def __init__(self, model_name: str = "tinyllama:1.1b"):  # Using tinyllama as it requires less memory
        """Initialize the PDF Reader AI with the specified Ollama model."""
        self.model_name = model_name
        self.text_chunks = []
        self.current_pdf = None
        
        # Load environment variables
        load_dotenv()
        
        # Initialize Ollama
        self.client = ollama.Client()
        
    def extract_text_from_pdf(self, pdf_path: str, chunk_size: int = 1000) -> List[str]:
        """
        Extract text from a PDF file and split it into chunks.
        
        Args:
            pdf_path: Path to the PDF file
            chunk_size: Maximum number of characters per chunk
            
        Returns:
            List of text chunks
        """
        if not os.path.exists(pdf_path):
            raise FileNotFoundError(f"PDF file not found: {pdf_path}")
            
        if not pdf_path.lower().endswith('.pdf'):
            raise ValueError("File must be a PDF")
            
        self.current_pdf = pdf_path
        self.text_chunks = []
        full_text = ""
        
        try:
            with pdfplumber.open(pdf_path) as pdf:
                for page in pdf.pages:
                    text = page.extract_text()
                    if text:
                        # Clean up text (remove extra whitespace, etc.)
                        text = re.sub(r'\s+', ' ', text).strip()
                        full_text += text + "\n\n"
            
            # Split text into chunks
            self.text_chunks = [full_text[i:i + chunk_size] 
                              for i in range(0, len(full_text), chunk_size)]
            
            return self.text_chunks
            
        except Exception as e:
            raise Exception(f"Error processing PDF: {str(e)}")
    
    def ask_question(self, question: str, max_chunks: int = 3) -> str:
        """
        Ask a question about the PDF content.
        
        Args:
            question: The question to ask
            max_chunks: Maximum number of chunks to process
            
        Returns:
            The answer from the model
        """
        if not self.text_chunks:
            raise ValueError("No PDF content loaded. Please load a PDF first.")
        
        print(f"\nDebug: Processing question: {question}")
        print(f"Debug: Using model: {self.model_name}")
        print(f"Debug: Number of text chunks: {len(self.text_chunks)}")
            
        # Process chunks and get answers
        answers = []
        for i, chunk in enumerate(self.text_chunks[:max_chunks]):
            try:
                print(f"\nDebug: Processing chunk {i+1}/{min(len(self.text_chunks), max_chunks)}")
                print(f"Debug: Chunk size: {len(chunk)} characters")
                
                # Prepare the prompt with the current chunk
                prompt = f"""You are a helpful assistant that answers questions based on the provided document.
Answer the following question based on the document content below.
If the answer cannot be found in the document, say 'I could not find an answer in the document.'

Question: {question}

Document content:
{chunk}

Answer:"""
                
                print("Debug: Sending request to Ollama...")
                response = self.client.chat(
                    model=self.model_name,
                    messages=[
                        {"role": "system", "content": "You are a helpful assistant that answers questions based on the provided document."},
                        {"role": "user", "content": prompt}
                    ]
                )
                
                if response and 'message' in response and 'content' in response['message']:
                    answer = response['message']['content'].strip()
                    print(f"Debug: Received answer: {answer[:100]}..." if len(answer) > 100 else f"Debug: Received answer: {answer}")
                    answers.append(answer)
                else:
                    print(f"Debug: Unexpected response format: {response}")
                    
            except Exception as e:
                print(f"Error getting response from model: {str(e)}")
                import traceback
                traceback.print_exc()
                continue
        
        # If no answers were generated, return an error message
        if not answers:
            error_msg = "I'm sorry, I couldn't generate an answer. Please check if Ollama is running and the model is downloaded."
            print(f"Debug: No answers were generated. Check Ollama service and model availability.")
            return error_msg
            
        # Return the first non-empty answer
        return answers[0] if answers[0].strip() else "I couldn't find an answer to that question in the document."

def main():
    parser = argparse.ArgumentParser(description="PDF Reader AI - Ask questions about your PDF documents")
    parser.add_argument("pdf_path", help="Path to the PDF file")
    parser.add_argument("-q", "--question", help="Question to ask about the PDF")
    parser.add_argument("-m", "--model", default="tinyllama:1.1b", 
                       help="Ollama model to use (default: tinyllama:1.1b)")
    
    args = parser.parse_args()
    
    try:
        # Initialize the PDF Reader
        reader = PDFReaderAI(model_name=args.model)
        
        # Extract text from PDF
        print(f"Loading PDF: {args.pdf_path}")
        reader.extract_text_from_pdf(args.pdf_path)
        print("PDF loaded successfully!")
        
        # If a question was provided, answer it
        if args.question:
            print(f"\nQuestion: {args.question}")
            print("\nSearching for answer...")
            answer = reader.ask_question(args.question)
            print(f"\nAnswer: {answer}")
        else:
            # Interactive mode
            print("\nEnter your questions about the PDF (type 'exit' to quit):")
            while True:
                question = input("\nQuestion: ").strip()
                if question.lower() in ['exit', 'quit']:
                    break
                if not question:
                    continue
                    
                print("\nSearching for answer...")
                answer = reader.ask_question(question)
                print(f"\nAnswer: {answer}")
                
    except Exception as e:
        print(f"Error: {str(e)}")
        return 1
    
    return 0

if __name__ == "__main__":
    main()
