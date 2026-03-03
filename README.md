
# Document Reader Backend (Rails API)

## Requirements
- Ruby 3.1+
- Bundler
- poppler-utils (for PDF text extraction)
- Node.js (for frontend, see below)

## Setup
1. Install dependencies:
	```sh
	bundle install
	```
2. Setup database:
	```sh
	rails db:create db:migrate
	```
3. Start the Rails server:
	```sh
	rails server -p 3001
	```
4. The API will be available at http://localhost:3001

## API Endpoints
- `POST /documents` — Upload a PDF or image file (multipart form, param: `document[file]`)
- `GET /documents/:id/extract` — Extract and return text from the uploaded PDF

## Frontend (Vite + React + TypeScript)
The recommended frontend is in `docreader-backend/docreader-frontend`.

### Setup Frontend
1. Open a new terminal and navigate to the frontend directory:
	```sh
	cd docreader-backend/docreader-frontend
	npm install
	npm run dev
	```
2. The app will be available at http://localhost:5173 (default Vite port)

## Usage
- Upload a PDF or image file using the React UI.
- Click 'Extract Text' to extract and view text from PDF files.
- Extracted text is stored in the database and can be retrieved via the backend.

## Notes
- CORS is enabled for local development.
- Only PDF, PNG, and JPEG files are supported.
