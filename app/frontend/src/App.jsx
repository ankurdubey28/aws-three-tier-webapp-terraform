import { useEffect, useMemo, useState } from "react";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8080";

const initialForm = {
  name: "",
  email: "",
  message: "",
};

function App() {
  const [form, setForm] = useState(initialForm);
  const [feedback, setFeedback] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");

  const apiUrl = useMemo(() => API_BASE_URL.replace(/\/$/, ""), []);

  useEffect(() => {
    loadFeedback();
  }, []);

  async function loadFeedback() {
    setIsLoading(true);
    setError("");

    try {
      const response = await fetch(`${apiUrl}/api/feedback/`);
      if (!response.ok) {
        throw new Error("Unable to load feedback");
      }

      setFeedback(await response.json());
    } catch (err) {
      setError(err.message);
    } finally {
      setIsLoading(false);
    }
  }

  function updateField(event) {
    const { name, value } = event.target;
    setForm((current) => ({ ...current, [name]: value }));
  }

  async function submitFeedback(event) {
    event.preventDefault();
    setIsSubmitting(true);
    setError("");
    setNotice("");

    try {
      const response = await fetch(`${apiUrl}/api/feedback/`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(form),
      });

      const payload = await response.json();
      if (!response.ok) {
        throw new Error(payload.error ?? "Unable to submit feedback");
      }

      setForm(initialForm);
      setFeedback((current) => [payload, ...current]);
      setNotice("Feedback submitted.");
    } catch (err) {
      setError(err.message);
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <main className="app">
      <section className="hero">
        <div>
          <p className="eyebrow">Three-tier demo app</p>
          <h1>Feedback Collector</h1>
          <p className="summary">
            A minimal React frontend connected to a Go API and PostgreSQL database.
          </p>
        </div>
      </section>

      <section className="layout">
        <form className="panel form" onSubmit={submitFeedback}>
          <h2>Send Feedback</h2>

          <label>
            Name
            <input
              name="name"
              type="text"
              value={form.name}
              onChange={updateField}
              maxLength="100"
              required
            />
          </label>

          <label>
            Email
            <input
              name="email"
              type="email"
              value={form.email}
              onChange={updateField}
              maxLength="254"
              required
            />
          </label>

          <label>
            Message
            <textarea
              name="message"
              value={form.message}
              onChange={updateField}
              maxLength="2000"
              rows="5"
              required
            />
          </label>

          {error && <p className="alert error">{error}</p>}
          {notice && <p className="alert success">{notice}</p>}

          <button type="submit" disabled={isSubmitting}>
            {isSubmitting ? "Submitting..." : "Submit"}
          </button>
        </form>

        <section className="panel feedback-list">
          <div className="list-header">
            <h2>Recent Feedback</h2>
            <button className="secondary" type="button" onClick={loadFeedback}>
              Refresh
            </button>
          </div>

          {isLoading ? (
            <p className="muted">Loading feedback...</p>
          ) : feedback.length === 0 ? (
            <p className="muted">No feedback yet.</p>
          ) : (
            <ul>
              {feedback.map((item) => (
                <li key={item.id}>
                  <div>
                    <strong>{item.name}</strong>
                    <span>{new Date(item.created_at).toLocaleString()}</span>
                  </div>
                  <p>{item.message}</p>
                </li>
              ))}
            </ul>
          )}
        </section>
      </section>
    </main>
  );
}

export default App;
