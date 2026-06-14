package feedback

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"time"
)

type Handler struct {
	store *Store
}

type createFeedbackRequest struct {
	Name    string `json:"name"`
	Email   string `json:"email"`
	Message string `json:"message"`
}

type feedbackResponse struct {
	ID        int64     `json:"id"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	Message   string    `json:"message"`
	CreatedAt time.Time `json:"created_at"`
}

func NewHandler(store *Store) *Handler {
	return &Handler{store: store}
}

func (h *Handler) Create(w http.ResponseWriter, r *http.Request) {
	var req createFeedbackRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		WriteJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid JSON request body"})
		return
	}

	input, err := validateCreateRequest(req)
	if err != nil {
		WriteJSON(w, http.StatusBadRequest, map[string]string{"error": err.Error()})
		return
	}

	item, err := h.store.Create(r.Context(), input)
	if err != nil {
		WriteJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to create feedback"})
		return
	}

	WriteJSON(w, http.StatusCreated, toResponse(item))
}

func (h *Handler) List(w http.ResponseWriter, r *http.Request) {
	items, err := h.store.List(r.Context(), 25)
	if err != nil {
		WriteJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to list feedback"})
		return
	}

	response := make([]feedbackResponse, 0, len(items))
	for _, item := range items {
		response = append(response, toResponse(item))
	}

	WriteJSON(w, http.StatusOK, response)
}

func validateCreateRequest(req createFeedbackRequest) (CreateFeedbackInput, error) {
	input := CreateFeedbackInput{
		Name:    strings.TrimSpace(req.Name),
		Email:   strings.TrimSpace(req.Email),
		Message: strings.TrimSpace(req.Message),
	}

	switch {
	case input.Name == "":
		return CreateFeedbackInput{}, errors.New("name is required")
	case input.Email == "":
		return CreateFeedbackInput{}, errors.New("email is required")
	case input.Message == "":
		return CreateFeedbackInput{}, errors.New("message is required")
	case len(input.Name) > 100:
		return CreateFeedbackInput{}, errors.New("name must be 100 characters or fewer")
	case len(input.Email) > 254:
		return CreateFeedbackInput{}, errors.New("email must be 254 characters or fewer")
	case len(input.Message) > 2000:
		return CreateFeedbackInput{}, errors.New("message must be 2000 characters or fewer")
	default:
		return input, nil
	}
}

func toResponse(item Feedback) feedbackResponse {
	return feedbackResponse{
		ID:        item.ID,
		Name:      item.Name,
		Email:     item.Email,
		Message:   item.Message,
		CreatedAt: item.CreatedAt,
	}
}
