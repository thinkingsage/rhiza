<script>
  import { onMount } from 'svelte';
  import * as d3 from 'd3';
  
  export let graphData;
  export let onClose;
  
  let container;
  
  onMount(() => {
    if (graphData && container) {
      renderGraph();
    }
  });
  
  function renderGraph() {
    const containerWidth = container.clientWidth || 600;
    const width = Math.min(containerWidth - 20, 600);
    const height = 400;
    
    const svg = d3.select(container)
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .style('border', '1px solid #ddd')
      .style('border-radius', '8px')
      .style('max-width', '100%');
    
    const g = svg.append('g');
    
    // Add zoom behavior
    const zoom = d3.zoom()
      .scaleExtent([0.5, 3])
      .on('zoom', (event) => {
        g.attr('transform', event.transform);
      });
    
    svg.call(zoom);
    
    // Create force simulation
    const simulation = d3.forceSimulation(graphData.nodes)
      .force('link', d3.forceLink(graphData.links).id(d => d.id).distance(100))
      .force('charge', d3.forceManyBody().strength(-300))
      .force('center', d3.forceCenter(width / 2, height / 2));
    
    // Draw links
    const link = g.selectAll('line')
      .data(graphData.links)
      .enter()
      .append('line')
      .attr('stroke', '#999')
      .attr('stroke-width', 2);
    
    // Draw nodes
    const node = g.selectAll('circle')
      .data(graphData.nodes)
      .enter()
      .append('circle')
      .attr('r', d => d.type === 'word' ? 15 : 10)
      .attr('fill', d => d.type === 'word' ? '#2c5aa0' : '#ff6b6b')
      .attr('stroke', '#fff')
      .attr('stroke-width', 2)
      .style('cursor', 'pointer');
    
    // Add labels
    const label = g.selectAll('text')
      .data(graphData.nodes)
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
  }
</script>

<div style="margin-top: 2rem; padding: 1.5rem; background: rgba(255,255,255,0.95); border-radius: 12px; box-shadow: 0 8px 32px rgba(0,0,0,0.1); max-width: 100%; overflow: hidden;">
  <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
    <h3 style="margin: 0;">Etymology Graph</h3>
    <button on:click={onClose} class="search-btn" style="padding: 0.5rem; min-width: auto;">×</button>
  </div>
  
  <div bind:this={container} style="width: 100%; max-width: 100%; overflow: hidden;"></div>
</div>
