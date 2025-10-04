// Graph visualization constants
export const CATEGORY_COLORS = {
  'emotion': '#ff6b6b',
  'abstract_concept': '#4ecdc4',
  'political': '#9b59b6',
  'academic': '#3498db',
  'nature': '#2ecc71',
  'psychology': '#e74c3c',
  'religion': '#f39c12',
  'human': '#34495e',
  'communication': '#e67e22',
  'perception': '#1abc9c',
  'distance': '#95a5a6',
  'size': '#8e44ad',
  'skill': '#16a085',
  'default': '#7f8c8d'
};

export const FREQUENCY_SIZES = {
  'very_high': 20,
  'high': 15,
  'medium': 12,
  'low': 10,
  'default': 12
};

export const GRAPH_CONFIG = {
  width: 600,
  height: 400,
  wordNodeRadius: 15,
  defaultStrokeWidth: 2
};

export const FILTER_CATEGORIES = [
  'abstract_concepts', 'body_parts', 'emotions', 'nature', 
  'science', 'philosophy', 'arts', 'social', 'time', 
  'spatial', 'actions', 'qualities', 'other'
];

export const FILTER_FREQUENCIES = ['very_high', 'high', 'medium', 'low'];
