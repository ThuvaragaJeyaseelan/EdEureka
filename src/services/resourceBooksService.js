import { supabase } from './supabase'

export const resourceBooksService = {
  async getResourceBooks(subjectId) {
    try {
      const { data, error } = await supabase
        .from('resource_books')
        .select('*')
        .eq('subject_id', subjectId)
        .eq('is_active', true)
        .order('created_at', { ascending: false })

      if (error) throw error

      // Get public URLs for PDFs from storage
      const booksWithUrls = await Promise.all(
        (data || []).map(async (book) => {
          if (book.pdf_path) {
            const { data: urlData } = supabase.storage
              .from('resource-books')
              .getPublicUrl(book.pdf_path)
            return {
              ...book,
              pdf_url: urlData.publicUrl
            }
          }
          return book
        })
      )

      return { success: true, data: booksWithUrls }
    } catch (error) {
      console.error('Error getting resource books:', error)
      return { success: false, error: error.message, data: [] }
    }
  },

  async getPublicUrl(pdfPath) {
    try {
      const { data } = supabase.storage
        .from('resource-books')
        .getPublicUrl(pdfPath)
      
      return data.publicUrl
    } catch (error) {
      console.error('Error getting public URL:', error)
      return null
    }
  },

  async uploadPDF(file, subjectId, bookId) {
    try {
      const fileExt = file.name.split('.').pop()
      const fileName = `${subjectId}/${bookId}_${Date.now()}.${fileExt}`
      
      const { data, error } = await supabase.storage
        .from('resource-books')
        .upload(fileName, file, {
          cacheControl: '3600',
          upsert: false
        })

      if (error) throw error

      return { success: true, path: data.path }
    } catch (error) {
      console.error('Error uploading PDF:', error)
      return { success: false, error: error.message }
    }
  }
}

