<script>
  import { slide } from 'svelte/transition';
  import { onMount } from 'svelte';
  import { renderGraph, applyEducationalMode } from '../graphRenderer.js';
  import GraphControls from './GraphControls.svelte';
  
  export let graphData;
  export let educationalMode;
  export let selectedCategories;
  export let selectedFrequencies;
  export let onClose;
  export let onCategoryToggle;
  export let onFrequencyToggle;
  export let onEducationalModeToggle;
  export let onClearFilters;
  
  let filteredGraphData = null;
  
  $: if (graphData) {
    filteredGraphData = graphData;
    applyFilters();
  }
  
  onMount(() => {
    if (graphData) {
      setTimeout(() => {
        renderGraph(graphData);
        applyEducationalMode(educationalMode);
      }, 100);
    }
  });
  
  function applyFilters() {
    if (!filteredGraphData) return;
    
    const hasFilters = selectedCategories.size > 0 || selectedFrequencies.size > 0;
    
    if (!hasFilters) {
      renderGraph(filteredGraphData);
      applyEducationalMode(educationalMode);
      return;
    }

    const filteredNodes = filteredGraphData.nodes.filter(node => {
      if (node.type === 'word') return true;
      
      const props = node.properties || {};
      const categoryMatch = selectedCategories.size === 0 || selectedCategories.has(props.category);
      const frequencyMatch = selectedFrequencies.size === 0 || selectedFrequencies.has(props.frequency);
      
      return categoryMatch && frequencyMatch;
    });

    const nodeIds = new Set(filteredNodes.map(n => n.id));
    const filteredLinks = filteredGraphData.links.filter(link => 
      nodeIds.has(link.source) && nodeIds.has(link.target)
    );

    renderGraph({ nodes: filteredNodes, links: filteredLinks });
    applyEducationalMode(educationalMode);
  }
  
  $: if (educationalMode !== undefined) {
    applyEducationalMode(educationalMode);
  }
</script>

<div class="graph-container" transition:slide={{ duration: 500 }}>
  <h3>Etymology Graph</h3>
  
  <div id="graph-viz"></div>
  
  <GraphControls 
    {selectedCategories}
    {selectedFrequencies}
    {educationalMode}
    {onCategoryToggle}
    {onFrequencyToggle}
    {onEducationalModeToggle}
    {onClearFilters}
  />
  
  <div class="legend">
    <h4>Legend</h4>
    <div class="legend-sections">
      <div class="legend-section">
        <h5>Node Colors (Categories)</h5>
        <div class="legend-items">
          <div class="legend-item"><div class="legend-color" style="background: #ff6b6b;"></div> Emotion</div>
          <div class="legend-item"><div class="legend-color" style="background: #4ecdc4;"></div> Abstract Concept</div>
          <div class="legend-item"><div class="legend-color" style="background: #9b59b6;"></div> Political</div>
          <div class="legend-item"><div class="legend-color" style="background: #3498db;"></div> Academic</div>
          <div class="legend-item"><div class="legend-color" style="background: #2ecc71;"></div> Nature</div>
        </div>
      </div>
      
      <div class="legend-section">
        <h5>Node Sizes (Frequency)</h5>
        <div class="legend-items">
          <div class="legend-item"><div class="legend-size very-high"></div> Very High</div>
          <div class="legend-item"><div class="legend-size high"></div> High</div>
          <div class="legend-item"><div class="legend-size medium"></div> Medium</div>
          <div class="legend-item"><div class="legend-size low"></div> Low</div>
        </div>
      </div>
      
      <div class="legend-section">
        <h5>Border Styles (Part of Speech)</h5>
        <div class="legend-items">
          <div class="legend-item"><div class="legend-border" style="border: 4px solid #333;"></div> Verb</div>
          <div class="legend-item"><div class="legend-border" style="border: 3px solid #333;"></div> Noun</div>
          <div class="legend-item"><div class="legend-border" style="border: 2px dashed #333;"></div> Adverb</div>
        </div>
      </div>
    </div>
  </div>
  
  <button class="graph-btn" on:click={onClose}>Close Graph</button>
</div>


