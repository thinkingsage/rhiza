# Contributing to Rhiza

Thank you for your interest in contributing to Rhiza! This guide will help you get started with contributing to our Greek etymology explorer.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/rhiza.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes
6. Submit a pull request

## Development Setup

### Prerequisites
- Docker and Docker Compose
- Python 3.11+ (for API development)
- Node.js 18+ (for UI development)

### Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Start development environment
docker compose up --build

# Run tests
cd rhiza-api && pytest
cd rhiza-ui && npm test
```

## Types of Contributions

### Bug Reports
- Use the issue template
- Include steps to reproduce
- Provide system information
- Include error messages and logs

### Feature Requests
- Describe the problem you're solving
- Explain your proposed solution
- Consider backwards compatibility
- Discuss implementation approach

### Code Contributions
- Follow existing code style
- Write tests for new features
- Update documentation
- Keep commits focused and atomic

## Code Style

### Python (API)
- Use Black for formatting: `black .`
- Use isort for imports: `isort .`
- Follow PEP 8 guidelines
- Add type hints
- Write docstrings for functions

### JavaScript/Svelte (UI)
- Use Prettier for formatting: `npm run format`
- Follow ESLint rules
- Use meaningful variable names
- Add JSDoc comments for complex functions

## Testing

### API Tests
```bash
cd rhiza-api
pytest tests/
```

### UI Tests
```bash
cd rhiza-ui
npm test
```

## Documentation

- Update README.md for user-facing changes
- Add inline code comments
- Update API documentation
- Include examples in docstrings

## Pull Request Process

1. Update documentation
2. Add tests for new features
3. Ensure all tests pass
4. Update CHANGELOG.md
5. Request review from maintainers

## Community Guidelines

- Be respectful and inclusive
- Help others learn and grow
- Focus on constructive feedback
- Celebrate diverse perspectives

---

# Συνεισφορά στη Ρίζα

Σας ευχαριστούμε για το ενδιαφέρον σας να συνεισφέρετε στη Ρίζα! Αυτός ο οδηγός θα σας βοηθήσει να ξεκινήσετε με τη συνεισφορά στον εξερευνητή ελληνικής ετυμολογίας.

## Ξεκινώντας

1. Κάντε fork το αποθετήριο
2. Κλωνοποιήστε το fork σας: `git clone https://github.com/your-username/rhiza.git`
3. Δημιουργήστε ένα branch χαρακτηριστικού: `git checkout -b feature/your-feature-name`
4. Κάντε τις αλλαγές σας
5. Δοκιμάστε τις αλλαγές σας
6. Υποβάλετε ένα pull request

## Ρύθμιση Ανάπτυξης

### Προαπαιτούμενα
- Docker και Docker Compose
- Python 3.11+ (για ανάπτυξη API)
- Node.js 18+ (για ανάπτυξη UI)

### Ρύθμιση Περιβάλλοντος
```bash
# Αντιγράψτε το πρότυπο περιβάλλοντος
cp .env.example .env

# Ξεκινήστε το περιβάλλον ανάπτυξης
docker compose up --build

# Εκτελέστε δοκιμές
cd rhiza-api && pytest
cd rhiza-ui && npm test
```

## Τύποι Συνεισφορών

### Αναφορές Σφαλμάτων
- Χρησιμοποιήστε το πρότυπο ζητήματος
- Συμπεριλάβετε βήματα αναπαραγωγής
- Παρέχετε πληροφορίες συστήματος
- Συμπεριλάβετε μηνύματα σφάλματος και αρχεία καταγραφής

### Αιτήματα Χαρακτηριστικών
- Περιγράψτε το πρόβλημα που λύνετε
- Εξηγήστε την προτεινόμενη λύση σας
- Εξετάστε τη συμβατότητα προς τα πίσω
- Συζητήστε την προσέγγιση υλοποίησης

### Συνεισφορές Κώδικα
- Ακολουθήστε το υπάρχον στυλ κώδικα
- Γράψτε δοκιμές για νέα χαρακτηριστικά
- Ενημερώστε την τεκμηρίωση
- Διατηρήστε τα commits εστιασμένα και ατομικά

## Στυλ Κώδικα

### Python (API)
- Χρησιμοποιήστε Black για μορφοποίηση: `black .`
- Χρησιμοποιήστε isort για εισαγωγές: `isort .`
- Ακολουθήστε τις οδηγίες PEP 8
- Προσθέστε υποδείξεις τύπου
- Γράψτε docstrings για συναρτήσεις

### JavaScript/Svelte (UI)
- Χρησιμοποιήστε Prettier για μορφοποίηση: `npm run format`
- Ακολουθήστε τους κανόνες ESLint
- Χρησιμοποιήστε σημαντικά ονόματα μεταβλητών
- Προσθέστε σχόλια JSDoc για πολύπλοκες συναρτήσεις

## Δοκιμές

### Δοκιμές API
```bash
cd rhiza-api
pytest tests/
```

### Δοκιμές UI
```bash
cd rhiza-ui
npm test
```

## Τεκμηρίωση

- Ενημερώστε το README.md για αλλαγές που αφορούν τον χρήστη
- Προσθέστε σχόλια κώδικα εντός γραμμής
- Ενημερώστε την τεκμηρίωση API
- Συμπεριλάβετε παραδείγματα στα docstrings

## Διαδικασία Pull Request

1. Ενημερώστε την τεκμηρίωση
2. Προσθέστε δοκιμές για νέα χαρακτηριστικά
3. Βεβαιωθείτε ότι όλες οι δοκιμές περνούν
4. Ενημερώστε το CHANGELOG.md
5. Ζητήστε αξιολόγηση από τους συντηρητές

## Οδηγίες Κοινότητας

- Να είστε σεβαστοί και συμπεριληπτικοί
- Βοηθήστε τους άλλους να μάθουν και να αναπτυχθούν
- Εστιάστε σε εποικοδομητικά σχόλια
- Γιορτάστε τις διαφορετικές οπτικές γωνίες
