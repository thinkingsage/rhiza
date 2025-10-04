// Enhanced D3.js Graph Visualization for Rhiza
// Uses enriched data properties for better visual representation

function createEnrichedGraph(data) {
  const width = 800;
  const height = 600;
  
  // Clear existing graph
  d3.select('#graph-viz').selectAll('*').remove();
  
  const svg = d3.select('#graph-viz')
    .append('svg')
    .attr('width', width)
    .attr('height', height);
  
  // Enhanced gradients and patterns
  const defs = svg.append('defs');
  
  // Category-based color schemes
  const categoryColors = {
    'emotion': ['#ff6b6b', '#ff8e8e'],
    'abstract_concept': ['#4ecdc4', '#7dd3d8'],
    'academic': ['#45b7d1', '#6bc5d2'],
    'nature': ['#96ceb4', '#a8d5ba'],
    'psychology': ['#dda0dd', '#e6b3e6'],
    'default': ['#95a5a6', '#b2bec3']
  };
  
  // Create gradients for each category
  Object.entries(categoryColors).forEach(([category, colors]) => {
    const gradient = defs.append('linearGradient')
      .attr('id', `gradient-${category}`)
      .attr('x1', '0%').attr('y1', '0%')
      .attr('x2', '100%').attr('y2', '100%');
    
    gradient.append('stop')
      .attr('offset', '0%')
      .attr('stop-color', colors[0]);
    
    gradient.append('stop')
      .attr('offset', '100%')
      .attr('stop-color', colors[1]);
  });
  
  // Enhanced glow filter
  const filter = defs.append('filter')
    .attr('id', 'enhanced-glow')
    .attr('x', '-50%').attr('y', '-50%')
    .attr('width', '200%').attr('height', '200%');
  
  filter.append('feGaussianBlur')
    .attr('stdDeviation', '3')
    .attr('result', 'coloredBlur');
  
  const feMerge = filter.append('feMerge');
  feMerge.append('feMergeNode').attr('in', 'coloredBlur');
  feMerge.append('feMergeNode').attr('in', 'SourceGraphic');
  
  // Zoom and pan
  const g = svg.append('g');
  const zoom = d3.zoom()
    .scaleExtent([0.3, 4])
    .on('zoom', (event) => {
      g.attr('transform', event.transform);
    });
  
  svg.call(zoom);
  
  // Enhanced force simulation
  const simulation = d3.forceSimulation(data.nodes)
    .force('link', d3.forceLink(data.edges).id(d => d.id).distance(d => {
      // Variable link distance based on relationship strength
      return d.properties?.strength ? (1 - d.properties.strength) * 150 + 80 : 120;
    }))
    .force('charge', d3.forceManyBody().strength(d => {
      // Stronger charge for high-frequency roots
      const baseStrength = -400;
      if (d.type === 'GreekRoot' && d.properties?.frequency === 'very_high') {
        return baseStrength * 1.5;
      }
      return baseStrength;
    }))
    .force('center', d3.forceCenter(width / 2, height / 2))
    .force('collision', d3.forceCollide().radius(d => {
      // Variable collision radius based on frequency
      const baseRadius = 25;
      if (d.properties?.frequency === 'very_high') return baseRadius * 1.4;
      if (d.properties?.frequency === 'high') return baseRadius * 1.2;
      return baseRadius;
    }));
  
  // Enhanced links with variable styling
  const link = g.append('g')
    .selectAll('line')
    .data(data.edges)
    .enter().append('line')
    .attr('stroke', d => {
      // Color links based on relationship strength
      const strength = d.properties?.strength || 0.5;
      const opacity = Math.max(0.3, strength);
      return `rgba(108, 117, 125, ${opacity})`;
    })
    .attr('stroke-width', d => {
      // Thicker lines for stronger relationships
      const strength = d.properties?.strength || 0.5;
      return Math.max(1, strength * 4);
    })
    .attr('stroke-dasharray', d => {
      // Dashed lines for weaker relationships
      const strength = d.properties?.strength || 0.5;
      return strength < 0.7 ? '5,5' : 'none';
    });
  
  // Enhanced nodes with category-based styling
  const node = g.append('g')
    .selectAll('circle')
    .data(data.nodes)
    .enter().append('circle')
    .attr('r', d => {
      // Size based on frequency and type
      let baseRadius = d.type === 'EnglishWord' ? 15 : 12;
      
      if (d.properties?.frequency === 'very_high') baseRadius *= 1.4;
      else if (d.properties?.frequency === 'high') baseRadius *= 1.2;
      else if (d.properties?.frequency === 'low') baseRadius *= 0.8;
      
      return baseRadius;
    })
    .attr('fill', d => {
      if (d.type === 'EnglishWord') {
        return 'url(#gradient-default)';
      } else if (d.type === 'GreekRoot') {
        const category = d.properties?.category || 'default';
        return `url(#gradient-${category})`;
      }
      return 'url(#gradient-default)';
    })
    .attr('stroke', d => {
      // Border color based on part of speech
      if (d.properties?.part_of_speech === 'noun') return '#2c3e50';
      if (d.properties?.part_of_speech === 'adjective') return '#e74c3c';
      if (d.properties?.part_of_speech === 'verb') return '#27ae60';
      return '#95a5a6';
    })
    .attr('stroke-width', d => {
      // Thicker border for high frequency
      return d.properties?.frequency === 'very_high' ? 4 : 2;
    })
    .style('filter', 'url(#enhanced-glow)')
    .style('cursor', 'pointer')
    .call(d3.drag()
      .on('start', dragstarted)
      .on('drag', dragged)
      .on('end', dragended));
  
  // Enhanced labels with better positioning
  const label = g.append('g')
    .selectAll('text')
    .data(data.nodes)
    .enter().append('text')
    .text(d => {
      if (d.type === 'GreekRoot') {
        return `${d.properties?.name || d.label}\n(${d.properties?.transliteration || ''})`;
      }
      return d.label;
    })
    .attr('text-anchor', 'middle')
    .attr('dy', d => d.type === 'EnglishWord' ? -20 : -18)
    .attr('font-size', d => {
      // Larger text for high frequency
      let baseSize = d.type === 'EnglishWord' ? 14 : 12;
      if (d.properties?.frequency === 'very_high') baseSize += 2;
      return `${baseSize}px`;
    })
    .attr('font-weight', d => {
      return d.properties?.frequency === 'very_high' ? 'bold' : 'normal';
    })
    .attr('fill', '#2d3748')
    .style('text-shadow', '0 1px 2px rgba(255,255,255,0.8)')
    .style('pointer-events', 'none');
  
  // Tooltips with enriched information
  const tooltip = d3.select('body').append('div')
    .attr('class', 'graph-tooltip')
    .style('opacity', 0)
    .style('position', 'absolute')
    .style('background', 'rgba(0,0,0,0.8)')
    .style('color', 'white')
    .style('padding', '8px')
    .style('border-radius', '4px')
    .style('font-size', '12px')
    .style('pointer-events', 'none');
  
  node.on('mouseover', function(event, d) {
    // Enhanced hover effects
    d3.select(this)
      .transition()
      .duration(200)
      .attr('r', d => {
        let currentRadius = parseFloat(d3.select(this).attr('r'));
        return currentRadius * 1.3;
      })
      .attr('stroke-width', 4);
    
    // Show enriched tooltip
    let tooltipContent = `<strong>${d.label}</strong><br/>`;
    if (d.properties?.meaning) tooltipContent += `Meaning: ${d.properties.meaning}<br/>`;
    if (d.properties?.category) tooltipContent += `Category: ${d.properties.category}<br/>`;
    if (d.properties?.frequency) tooltipContent += `Frequency: ${d.properties.frequency}<br/>`;
    if (d.properties?.part_of_speech) tooltipContent += `Part of Speech: ${d.properties.part_of_speech}`;
    
    tooltip.transition()
      .duration(200)
      .style('opacity', .9);
    tooltip.html(tooltipContent)
      .style('left', (event.pageX + 10) + 'px')
      .style('top', (event.pageY - 28) + 'px');
  })
  .on('mouseout', function(event, d) {
    d3.select(this)
      .transition()
      .duration(200)
      .attr('r', d => {
        let currentRadius = parseFloat(d3.select(this).attr('r'));
        return currentRadius / 1.3;
      })
      .attr('stroke-width', d => d.properties?.frequency === 'very_high' ? 4 : 2);
    
    tooltip.transition()
      .duration(500)
      .style('opacity', 0);
  });
  
  // Animation and simulation
  simulation.on('tick', () => {
    link
      .attr('x1', d => d.source.x)
      .attr('y1', d => d.source.y)
      .attr('x2', d => d.target.x)
      .attr('y2', d => d.target.y);
    
    node
      .attr('cx', d => d.x)
      .attr('cy', d => d.y);
    
    label
      .attr('x', d => d.x)
      .attr('y', d => d.y);
  });
  
  // Drag functions
  function dragstarted(event, d) {
    if (!event.active) simulation.alphaTarget(0.3).restart();
    d.fx = d.x;
    d.fy = d.y;
  }
  
  function dragged(event, d) {
    d.fx = event.x;
    d.fy = event.y;
  }
  
  function dragended(event, d) {
    if (!event.active) simulation.alphaTarget(0);
    d.fx = null;
    d.fy = null;
  }
  
  // Legend for categories
  const legend = svg.append('g')
    .attr('class', 'legend')
    .attr('transform', 'translate(20, 20)');
  
  const categories = Object.keys(categoryColors).filter(c => c !== 'default');
  
  legend.selectAll('.legend-item')
    .data(categories)
    .enter().append('g')
    .attr('class', 'legend-item')
    .attr('transform', (d, i) => `translate(0, ${i * 25})`)
    .each(function(d) {
      const g = d3.select(this);
      
      g.append('circle')
        .attr('r', 8)
        .attr('fill', `url(#gradient-${d})`);
      
      g.append('text')
        .attr('x', 15)
        .attr('y', 4)
        .text(d.replace('_', ' '))
        .attr('font-size', '12px')
        .attr('fill', '#2d3748');
    });
}

// Export for use in Svelte component
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { createEnrichedGraph };
}
