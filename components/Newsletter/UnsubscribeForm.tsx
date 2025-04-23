import { useState } from 'react'
import toast, { Toaster } from 'react-hot-toast'
import validator from 'validator'
import style from './newsletterform.module.css'

const isDevelopment = true //TODO

const UnsubscribeForm = () => {
  const [email, setEmail] = useState('')
  const [isLoading, setIsLoading] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()

    if (!validator.isEmail(email)) {
      toast.error('Invalid email format')
      return
    }

    setIsLoading(true)

    try {
      const response = await fetch('/api/unsubscribe', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }),
      })

      if (response.status === 200) {
        toast.success('Unsubscription successful')
        setEmail('')
      } else if (response.status === 404) {
        toast.error('Subscriber not found')
      } else {
        toast.error('Unsubscription failed')
      }
    } catch {
      toast.error('Unsubscription failed')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className={style.container}>
      <br />
      <Toaster position="bottom-center" reverseOrder={false} />
      <div className={style[`form-wrapper`]}>
        <h2 className={style[`form-title`]}>Unsubscribe From Our Newsletter</h2>
        <form onSubmit={handleSubmit} className={style[`form-container`]}>
          <input
            type="email"
            placeholder={isDevelopment ? 'Coming soon...' : 'Enter your email'}
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className={style[`email-input`]}
            readOnly={isDevelopment}
          />
          <button
            type="submit"
            className={style[`subscribe-button`]}
            disabled={isLoading || isDevelopment}
          >
            {isLoading ? 'Unsubscribing...' : 'Unsubscribe'}
          </button>
        </form>
      </div>
    </div>
  )
}

export default UnsubscribeForm
