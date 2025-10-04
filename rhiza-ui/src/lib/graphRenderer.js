import * as d3 from 'd3';
import { CATEGORY_COLORS, FREQUENCY_SIZES, GRAPH_CONFIG } from './constants.js';

function getCategoryColor(category) {
  return CATEGORY_COLORS[category] || CATEGORY_COLORS.default;
}

export function renderGraph(data, containerId = 'graph-viz') {
  const container = document.getElementById(containerId);
  container.innerHTML = '';
  
  d3.selectAll('.tooltip').remove();
  
  if (typeof d3 === 'undefined') {
    container.innerHTML = '<p style="color: red; text-align: center; padding: 20px;">D3.js library not loaded. Please refresh the page.</p>';
    return;
  }
  
  const { width, height } = GRAPH_CONFIG;
  
  const svg = d3.select(`#${containerId}`)
    .append('svg')
    .attr('width', width)
    .attr('height', height)
    .style('border', '1px solid #ddd')
    .style('border-radius', '8px')
    .style('background', 'linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)');
  
  const g = svg.append('g');
  
  const zoom = d3.zoom()
    .scaleExtent([0.5, 3])
    .on('zoom', (event) => {
      g.attr('transform', event.transform);
    });
  
  svg.call(zoom);
  
  // Initialize node positions
  data.nodes.forEach((node) => {
    node.x = width / 2 + (Math.random() - 0.5) * 20;
    node.y = height / 2 + (Math.random() - 0.5) * 20;
  });
  
  // Create force simulation
  const simulation = d3.forceSimulation(data.nodes)
    .force('collision', d3.forceCollide().radius(30))
    .force('center', d3.forceCenter(width / 2, height / 2))
    .force('link', d3.forceLink(data.links).id(d => d.id).distance(80).strength(0.8))
    .force('charge', d3.forceManyBody().strength(-200));
  
  // Center on the main word node
  const wordNode = data.nodes.find(n => n.type === 'word');
  if (wordNode) {
    const centerX = width / 2 - wordNode.x;
    const centerY = height / 2 - wordNode.y;
    const initialTransform = d3.zoomIdentity.translate(centerX, centerY).scale(1);
    svg.call(zoom.transform, initialTransform);
  }
  
  // Draw links
  g.selectAll('line')
    .data(data.links)
    .enter()
    .append('line')
    .attr('stroke', d => {
      const sourceNode = data.nodes.find(n => n.id === d.source);
      const targetNode = data.nodes.find(n => n.id === d.target);
      const rootNode = sourceNode.type === 'root' ? sourceNode : targetNode;
      
      if (rootNode.properties?.frequency === 'very_high') return '#4caf50';
      if (rootNode.properties?.frequency === 'high') return '#8bc34a';
      if (rootNode.properties?.frequency === 'medium') return '#ffc107';
      if (rootNode.properties?.frequency === 'low') return '#ff9800';
      return '#999';
    })
    .attr('stroke-width', d => {
      const sourceNode = data.nodes.find(n => n.id === d.source);
      const targetNode = data.nodes.find(n => n.id === d.target);
      const rootNode = sourceNode.type === 'root' ? sourceNode : targetNode;
      
      if (rootNode.properties?.frequency === 'very_high') return 4;
      if (rootNode.properties?.frequency === 'high') return 3;
      return 2;
    })
    .attr('opacity', d => {
      const sourceNode = data.nodes.find(n => n.id === d.source);
      const targetNode = data.nodes.find(n => n.id === d.target);
      const rootNode = sourceNode.type === 'root' ? sourceNode : targetNode;
      
      if (rootNode.properties?.frequency === 'very_high') return 0.9;
      if (rootNode.properties?.frequency === 'high') return 0.8;
      return 0.6;
    });
  
  // Create tooltip
  const tooltip = d3.select('body').append('div')
    .attr('class', 'tooltip')
    .style('position', 'absolute')
    .style('background', 'rgba(0, 0, 0, 0.9)')
    .style('color', 'white')
    .style('padding', '12px')
    .style('border-radius', '8px')
    .style('font-size', '12px')
    .style('max-width', '300px')
    .style('box-shadow', '0 4px 12px rgba(0,0,0,0.3)')
    .style('backdrop-filter', 'blur(10px)')
    .style('border', '1px solid rgba(255,255,255,0.1)')
    .style('opacity', 0)
    .style('pointer-events', 'none')
    .style('z-index', 1000);
  
  // Draw nodes
  g.selectAll('circle')
    .data(data.nodes)
    .enter()
    .append('circle')
    .attr('r', d => {
      if (d.type === 'word') return GRAPH_CONFIG.wordNodeRadius;
      const freq = d.properties?.frequency || 'default';
      return FREQUENCY_SIZES[freq] || FREQUENCY_SIZES.default;
    })
    .attr('fill', d => {
      if (d.type === 'word') return '#2c5aa0';
      const category = d.properties?.category || 'default';
      return getCategoryColor(category);
    })
    .attr('stroke', '#fff')
    .attr('stroke-width', d => {
      if (d.type === 'word') return 2;
      const pos = d.properties?.part_of_speech;
      if (pos === 'noun') return 3;
      if (pos === 'adjective') return 2;
      if (pos === 'verb') return 4;
      return 2;
    })
    .attr('stroke-dasharray', d => {
      if (d.type === 'word') return 'none';
      const pos = d.properties?.part_of_speech;
      if (pos === 'adjective') return '5,3';
      if (pos === 'adverb') return '2,2';
      return 'none';
    })
    .style('cursor', 'pointer')
    .on('mouseover', function(event, d) {
      let tooltipContent = `<div style="border-bottom: 1px solid rgba(255,255,255,0.2); padding-bottom: 8px; margin-bottom: 8px;">
        <strong style="font-size: 14px; color: #4fc3f7;">${d.label}</strong>
        <span style="font-size: 11px; color: #aaa; margin-left: 8px;">${d.type}</span>
      </div>`;
      
      if (d.type === 'root' && d.properties) {
        const props = d.properties;
        
        if (props.transliteration) {
          tooltipContent += `<div style="margin-bottom: 4px;">
            <span style="color: #81c784; font-weight: 500;">Transliteration:</span> ${props.transliteration}
          </div>`;
        }
        
        if (props.meaning) {
          tooltipContent += `<div style="margin-bottom: 4px;">
            <span style="color: #ffb74d; font-weight: 500;">Meaning:</span> ${props.meaning}
          </div>`;
        }
        
        if (props.category) {
          const categoryColor = getCategoryColor(props.category);
          tooltipContent += `<div style="margin-bottom: 4px;">
            <span style="color: #f48fb1; font-weight: 500;">Category:</span> 
            <span style="color: ${categoryColor}; font-weight: 500;">${props.category}</span>
          </div>`;
        }
        
        if (props.frequency) {
          const freqColor = props.frequency === 'very_high' ? '#4caf50' : 
                           props.frequency === 'high' ? '#8bc34a' : '#ffc107';
          tooltipContent += `<div style="margin-bottom: 4px;">
            <span style="color: #ce93d8; font-weight: 500;">Frequency:</span> 
            <span style="color: ${freqColor}; font-weight: 500;">${props.frequency.replace('_', ' ')}</span>
          </div>`;
        }
        
        if (props.part_of_speech) {
          tooltipContent += `<div style="margin-bottom: 4px;">
            <span style="color: #90caf9; font-weight: 500;">Part of Speech:</span> ${props.part_of_speech}
          </div>`;
        }
        
        if (props.etymology_notes) {
          tooltipContent += `<div style="margin-top: 8px; padding-top: 8px; border-top: 1px solid rgba(255,255,255,0.1); font-style: italic; color: #ccc;">
            ${props.etymology_notes}
          </div>`;
        }
      }
      
      tooltip.transition().duration(200).style('opacity', 1);
      tooltip.html(tooltipContent)
        .style('left', (event.pageX + 15) + 'px')
        .style('top', (event.pageY - 10) + 'px');
    })
    .on('mouseout', function() {
      tooltip.transition().duration(200).style('opacity', 0);
    });
  
  // Draw labels
  g.selectAll('text')
    .data(data.nodes)
    .enter()
    .append('text')
    .attr('dy', '.35em')
    .attr('text-anchor', 'middle')
    .attr('font-size', '12px')
    .attr('fill', '#333')
    .text(d => d.label)
    .style('pointer-events', 'none');
  
  // Update positions on simulation tick
  simulation.on('tick', () => {
    g.selectAll('line')
      .attr('x1', d => d.source.x)
      .attr('y1', d => d.source.y)
      .attr('x2', d => d.target.x)
      .attr('y2', d => d.target.y);
    
    g.selectAll('circle')
      .attr('cx', d => d.x)
      .attr('cy', d => d.y);
    
    g.selectAll('text')
      .attr('x', d => d.x)
      .attr('y', d => d.y);
  });
}

export function applyEducationalMode(mode, containerId = 'graph-viz') {
  const container = document.getElementById(containerId);
  const svg = d3.select(container).select('svg');
  
  if (mode === 'category') {
    svg.selectAll('circle')
      .transition()
      .duration(300)
      .attr('stroke-width', d => d.properties?.category ? 4 : 1)
      .attr('opacity', d => d.properties?.category ? 1 : 0.3);
  } else if (mode === 'grammar') {
    svg.selectAll('circle')
      .transition()
      .duration(300)
      .attr('stroke-width', d => d.properties?.part_of_speech ? 5 : 1)
      .attr('opacity', d => d.properties?.part_of_speech ? 1 : 0.3);
  } else {
    svg.selectAll('circle')
      .transition()
      .duration(300)
      .attr('stroke-width', d => {
        const pos = d.properties?.part_of_speech;
        if (pos === 'noun') return 3;
        if (pos === 'verb') return 2;
        return 1;
      })
      .attr('opacity', 1);
  }
}
