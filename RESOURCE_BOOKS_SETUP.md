# Resource Books PDF Setup Guide

This guide explains how to set up Supabase Storage for PDF resource books and add books to your database.

## Step 1: Create Supabase Storage Bucket

1. Go to your Supabase project dashboard
2. Navigate to **Storage** in the left sidebar
3. Click **New bucket**
4. Name: `resource-books`
5. **Make it public**: ✅ Check this box (so PDFs can be accessed without authentication)
6. Click **Create bucket**

## Step 2: Set Storage Policies

After creating the bucket, set up policies:

1. Click on the `resource-books` bucket
2. Go to **Policies** tab
3. Click **New Policy**
4. Select **For full customization**
5. Add this policy:

**Policy Name**: `Public read access`
**Allowed operation**: SELECT
**Policy definition**:
```sql
bucket_id = 'resource-books'
```

6. Click **Review** and **Save policy**

## Step 3: Upload PDF Files

### Option A: Using Supabase Dashboard

1. Go to **Storage** → `resource-books` bucket
2. Click **Upload file**
3. Upload your PDF files
4. **Important**: Organize files by subject ID folder structure:
   - `{subject-id}/book-{id}_{timestamp}.pdf`
   - Example: `c39cab32-9c03-4b12-ab4d-ea6471e9d922/book-1_1234567890.pdf`

### Option B: Using SQL (Recommended)

After uploading PDFs, you'll need to add book records to the database.

## Step 4: Add Books to Database

Run this SQL in your Supabase SQL Editor to add sample books:

```sql
-- First, get your subject IDs (run this to see them)
SELECT id, name FROM subjects;

-- Then insert books (replace subject_id with actual IDs from above)
-- Example for Combined Maths (replace with actual subject_id):
INSERT INTO resource_books (subject_id, title, author, description, edition, isbn, pdf_path, is_active)
VALUES 
  (
    (SELECT id FROM subjects WHERE name = 'Combined Maths' LIMIT 1),
    'Combined Mathematics - Volume 1',
    'S. L. Loney',
    'Comprehensive guide covering algebra, trigonometry, and coordinate geometry.',
    'Latest Edition',
    '978-0-123456-78-9',
    'combined-maths/volume1.pdf', -- Path in storage bucket
    true
  ),
  (
    (SELECT id FROM subjects WHERE name = 'Combined Maths' LIMIT 1),
    'Combined Mathematics - Volume 2',
    'S. L. Loney',
    'Advanced topics including calculus, complex numbers, and vectors.',
    'Latest Edition',
    '978-0-123456-79-6',
    'combined-maths/volume2.pdf',
    true
  );

-- Repeat for other subjects (Physics, Chemistry, Biology)
-- Example for Physics:
INSERT INTO resource_books (subject_id, title, author, description, edition, isbn, pdf_path, is_active)
VALUES 
  (
    (SELECT id FROM subjects WHERE name = 'Physics' LIMIT 1),
    'A Level Physics',
    'Roger Muncaster',
    'Comprehensive physics textbook covering mechanics, waves, electricity, and modern physics.',
    '4th Edition',
    '978-0-7487-1584-2',
    'physics/alevel-physics.pdf',
    true
  );
```

## Step 5: Verify Setup

1. Go to your app and navigate to a subject page
2. Click on **Resource Books** card
3. You should see the books listed
4. Click **View PDF** on any book with a PDF
5. The PDF should open in a viewer modal

## File Naming Convention

When uploading PDFs to Supabase Storage, use this structure:

```
resource-books/
  ├── {subject-id}/
  │   ├── book-{id}_{timestamp}.pdf
  │   └── book-{id}_{timestamp}.pdf
  └── {another-subject-id}/
      └── book-{id}_{timestamp}.pdf
```

Or use simpler names:
```
resource-books/
  ├── combined-maths/
  │   ├── volume1.pdf
  │   └── volume2.pdf
  ├── physics/
  │   └── alevel-physics.pdf
  └── chemistry/
      └── organic-chemistry.pdf
```

## Troubleshooting

### PDF not showing?
1. Check that the bucket is **public**
2. Verify the `pdf_path` in the database matches the file path in storage
3. Check browser console for errors
4. Ensure the PDF file was uploaded successfully

### Getting 403 Forbidden?
- Make sure the storage bucket has public read access
- Check that the storage policy is set correctly

### PDF path not found?
- Verify the path in the database matches exactly (case-sensitive)
- Check that the file exists in the storage bucket
- Ensure there are no extra spaces or special characters

## Example: Complete Book Entry

```sql
-- Get subject ID first
SELECT id FROM subjects WHERE name = 'Biology' LIMIT 1;

-- Insert book (replace {subject-id} with actual ID)
INSERT INTO resource_books (
  subject_id, 
  title, 
  author, 
  description, 
  edition, 
  isbn, 
  pdf_path, 
  is_active
) VALUES (
  '{subject-id}', -- Replace with actual subject UUID
  'Campbell Biology',
  'Lisa A. Urry, Michael L. Cain & Steven A. Wasserman',
  'Comprehensive biology textbook with excellent illustrations and examples.',
  '11th Edition',
  '978-0-13-409341-3',
  'biology/campbell-biology.pdf', -- Path in storage
  true
);
```

## Notes

- PDF files can be large. Consider compressing them before upload
- Supabase free tier has storage limits - check your plan
- Public buckets allow anyone with the URL to access files
- For private PDFs, you'd need to implement signed URLs (more complex)

