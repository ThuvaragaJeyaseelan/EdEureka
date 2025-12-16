export const validators = {
  email(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!email) {
      return 'Email is required'
    }
    if (!emailRegex.test(email)) {
      return 'Please enter a valid email address'
    }
    return null
  },

  password(password) {
    if (!password) {
      return 'Password is required'
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters'
    }
    return null
  },

  confirmPassword(password, confirmPassword) {
    if (!confirmPassword) {
      return 'Please confirm your password'
    }
    if (password !== confirmPassword) {
      return 'Passwords do not match'
    }
    return null
  },

  name(name) {
    if (!name) {
      return 'Name is required'
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters'
    }
    return null
  },

  required(value, fieldName = 'This field') {
    if (!value || (typeof value === 'string' && value.trim() === '')) {
      return `${fieldName} is required`
    }
    return null
  }
}

