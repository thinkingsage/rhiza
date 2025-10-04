# 🌟 Rhiza UI

> **Beautiful, interactive frontend for exploring Greek etymology**

Rhiza UI is a modern SvelteKit application that provides an elegant interface for discovering the Ancient Greek roots of English words. With smooth animations, interactive graph visualizations, and a classical design aesthetic, it makes etymology exploration both educational and delightful.

## ✨ Features

- 🎨 **Beautiful Design** - Glass morphism effects with classical Greek-inspired styling
- 📊 **Interactive Graphs** - D3.js force-directed visualizations with zoom and pan
- ⚡ **Smooth Animations** - Fade transitions and slide effects for enhanced UX
- 🔍 **Smart Search** - Real-time etymology analysis with input validation
- 📱 **Responsive** - Works seamlessly across desktop and mobile devices
- 🎭 **Typography** - Crimson Text for Greek characters, Inter for modern readability
- 🌐 **Production Ready** - Optimized builds with security headers

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ 
- pnpm (recommended) or npm
- Rhiza API running (see [rhiza-api](../rhiza-api/README.md))

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/rhiza.git
cd rhiza/rhiza-ui

# Install dependencies
pnpm install
# or
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your API configuration
```

### Environment Configuration

Create a `.env` file:

```bash
# API Configuration
VITE_API_URL=http://localhost:8000

# For production deployment
# VITE_API_URL=https://your-api-domain.com
```

### Development

```bash
# Start development server
pnpm dev
# or
npm run dev

# Open http://localhost:5173
```

### Building for Production

```bash
# Create optimized build
pnpm build
# or
npm run build

# Preview production build
pnpm preview
# or
npm run preview
```

## 🐳 Docker Deployment

```bash
# Build the container
docker build -t rhiza-ui .

# Run with nginx
docker run -p 80:8080 rhiza-ui
```

## 🎯 Usage

### Basic Etymology Search

1. **Enter a word** in the search field
2. **Click "Search"** or press Enter
3. **View results** with Greek roots, transliterations, and meanings
4. **Explore graph** by clicking "Show Graph" for visual relationships

### Interactive Graph Features

- **Zoom** - Mouse wheel or pinch to zoom in/out (0.5x - 3x)
- **Pan** - Click and drag to move around the graph
- **Hover Effects** - Nodes grow and glow on mouseover
- **Visual Hierarchy** - Different colors for words vs. roots

### Example Searches

Try these words to see the etymology in action:

- `philosophy` → φίλος (loving) + σοφία (wisdom)
- `democracy` → δῆμος (people) + κρατία (power)
- `biology` → βίος (life) + λόγος (study)
- `psychology` → ψυχή (soul) + λόγος (study)

## 🏗️ Architecture

### Tech Stack

- **SvelteKit** - Modern reactive framework with SSG
- **D3.js** - Data-driven graph visualizations
- **Vite** - Fast build tool and dev server
- **TypeScript** - Type safety and better DX
- **CSS3** - Modern styling with gradients and animations

### Key Components

```
src/
├── routes/
│   ├── +layout.svelte    # Global layout and styling
│   └── +page.svelte      # Main etymology search interface
├── app.html              # HTML template
└── app.css              # Global styles and design system
```

### Design System

- **Colors** - Classical blue and gold palette with gradients
- **Typography** - Crimson Text (Greek), Inter (Latin)
- **Effects** - Glass morphism, subtle shadows, smooth transitions
- **Layout** - Centered, responsive design with proper spacing

## 🎨 Customization

### Styling

The design system is built with CSS custom properties:

```css
:root {
  --font-greek: 'Crimson Text', serif;
  --font-sans: 'Inter', sans-serif;
  --color-primary: #2c5aa0;
  --color-secondary: #e74c3c;
  --glass-bg: rgba(255, 255, 255, 0.9);
}
```

### Graph Visualization

Customize the D3.js graph in `+page.svelte`:

```javascript
// Force simulation parameters
.force('link', d3.forceLink(data.links).distance(120))
.force('charge', d3.forceManyBody().strength(-300))
.force('collision', d3.forceCollide().radius(30))

// Visual styling
const wordGradient = 'url(#wordGradient)';  // Purple-blue
const rootGradient = 'url(#rootGradient)';  // Pink-red
```

## 🔧 Configuration

### API Integration

The UI communicates with the Rhiza API through configurable endpoints:

```javascript
// Environment-based API URL
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

// API calls
fetch(`${API_BASE_URL}/word/${word}`)           // Etymology analysis
fetch(`${API_BASE_URL}/word/${word}/graph`)    // Graph data
```

### Build Optimization

- **Static Generation** - Pre-rendered for optimal performance
- **Code Splitting** - Automatic chunking for faster loads
- **Asset Optimization** - Compressed images and minified code
- **Caching** - Proper cache headers for static assets

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](../CONTRIBUTING.md) for details.

### Development Workflow

```bash
# Install dependencies
pnpm install

# Start development server
pnpm dev

# Run linting
pnpm lint

# Format code
pnpm format

# Build for production
pnpm build
```

### Adding Features

1. **Search Enhancements** - Improve input validation or suggestions
2. **Visualization Options** - Add new graph layouts or styling
3. **Accessibility** - Enhance keyboard navigation and screen readers
4. **Mobile Experience** - Optimize touch interactions

## 📱 Browser Support

- **Modern Browsers** - Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- **Mobile** - iOS Safari 14+, Chrome Mobile 90+
- **Features Used** - ES2020, CSS Grid, Flexbox, CSS Custom Properties

## 🚀 Deployment

### Static Hosting

The built application is a static site that can be deployed to:

- **Netlify** - `pnpm build` → deploy `build/` folder
- **Vercel** - Automatic deployment with SvelteKit adapter
- **GitHub Pages** - Static hosting with custom domain support
- **AWS S3** - Static website hosting with CloudFront CDN

### Docker Deployment

```dockerfile
# Multi-stage build for optimal size
FROM node:20-alpine AS builder
# ... build steps ...

FROM nginx:stable-alpine
# ... serve static files ...
```

## 📄 License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0) - see the [LICENSE](../LICENSE) file for details.

**Key points about AGPL-3.0:**
- ✅ Free to use, modify, and distribute
- ✅ Must provide source code to users (including network users)
- ✅ Derivative works must also be AGPL-3.0 licensed
- ⚠️ Network use triggers copyleft obligations

## 🙏 Acknowledgments

- **SvelteKit Team** - Amazing reactive framework
- **D3.js Community** - Powerful visualization library
- **Greek Typography** - Crimson Text font family
- **Design Inspiration** - Classical Greek aesthetics

## 📞 Support

- 📖 [Documentation](https://github.com/your-username/rhiza/wiki)
- 🐛 [Issue Tracker](https://github.com/your-username/rhiza/issues)
- 💬 [Discussions](https://github.com/your-username/rhiza/discussions)
- 🎨 [Design System](https://github.com/your-username/rhiza/wiki/Design-System)

---

**Explore the roots of language with beautiful, interactive etymology** 🌱✨
