package feedback

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Store struct {
	db *pgxpool.Pool
}

type Feedback struct {
	ID        int64
	Name      string
	Email     string
	Message   string
	CreatedAt time.Time
}

type CreateFeedbackInput struct {
	Name    string
	Email   string
	Message string
}

func NewStore(db *pgxpool.Pool) *Store {
	return &Store{db: db}
}

func (s *Store) Create(ctx context.Context, input CreateFeedbackInput) (Feedback, error) {
	const query = `
		INSERT INTO feedback (name, email, message)
		VALUES ($1, $2, $3)
		RETURNING id, name, email, message, created_at
	`

	var item Feedback
	err := s.db.QueryRow(ctx, query, input.Name, input.Email, input.Message).Scan(
		&item.ID,
		&item.Name,
		&item.Email,
		&item.Message,
		&item.CreatedAt,
	)

	return item, err
}

func (s *Store) List(ctx context.Context, limit int) ([]Feedback, error) {
	const query = `
		SELECT id, name, email, message, created_at
		FROM feedback
		ORDER BY created_at DESC
		LIMIT $1
	`

	rows, err := s.db.Query(ctx, query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	items := make([]Feedback, 0)
	for rows.Next() {
		var item Feedback
		if err := rows.Scan(&item.ID, &item.Name, &item.Email, &item.Message, &item.CreatedAt); err != nil {
			return nil, err
		}

		items = append(items, item)
	}

	return items, rows.Err()
}
