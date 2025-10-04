<script>
  import { fade, slide } from 'svelte/transition';
  
  // This block contains our JavaScript logic
  let wordToSearch = '';
  let isLoading = false;
  let searchResult = null;
  let errorMessage = null;
  let showGraphViz = false;

  // API base URL - use environment variable or default to localhost
  const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

  async function searchForRoot() {
    if (!wordToSearch.trim()) return;

    isLoading = true;
    searchResult = null;
    errorMessage = null;
    showGraphViz = false; // Close graph when searching new word

    try {
      // Fetch both etymology and graph data
      const [etymologyResponse, graphResponse] = await Promise.all([
        fetch(`${API_BASE_URL}/word/${wordToSearch.trim()}`),
        fetch(`${API_BASE_URL}/word/${wordToSearch.trim()}/graph`)
      ]);

      if (!etymologyResponse.ok) {
        const errorData = await etymologyResponse.json().catch(() => ({}));
        const errorMsg = errorData.detail || `Server error (${etymologyResponse.status})`;
        throw new Error(errorMsg);
      }

      const etymologyData = await etymologyResponse.json();
      
      // Handle graph data (may fail if endpoint doesn't exist yet)
      let graphData = null;
      if (graphResponse.ok) {
        graphData = await graphResponse.json();
      }

      searchResult = { ...etymologyData, graphData };
    } catch (error) {
      errorMessage = error.message;
      console.error('Failed to fetch word roots:', error);
    } finally {
      isLoading = false;
    }
  }

  async function showGraph(word) {
    try {
      const response = await fetch(`${API_BASE_URL}/word/${word}/graph`);
      const graphData = await response.json();
      
      if (graphData.nodes.length > 0) {
        showGraphViz = true;
        setTimeout(() => renderGraph(graphData), 100);
      }
    } catch (error) {
      console.error('Failed to fetch graph data:', error);
    }
  }

  function renderGraph(data) {
    const container = document.getElementById('graph-viz');
    container.innerHTML = '';
    
    // Use enriched graph if we have the enhanced data
    if (data.nodes && data.edges) {
      createEnrichedGraph(data);
      return;
    }
    
    // Fallback to simple graph for basic data
    const width = 500;
    const height = 400;
    
    const svg = d3.select('#graph-viz')
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .style('background', 'linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)')
      .style('border-radius', '12px')
      .style('box-shadow', '0 8px 32px rgba(0, 0, 0, 0.1)');
    
    // Add zoom behavior
    const zoom = d3.zoom()
      .scaleExtent([0.5, 3])
      .on('zoom', (event) => {
        g.attr('transform', event.transform);
      });
    
    svg.call(zoom);
    
    // Create main group for all graph elements
    const g = svg.append('g');
    
    // Add gradient definitions
    const defs = svg.append('defs');
    
    const wordGradient = defs.append('linearGradient')
      .attr('id', 'wordGradient')
      .attr('x1', '0%').attr('y1', '0%')
      .attr('x2', '100%').attr('y2', '100%');
    wordGradient.append('stop').attr('offset', '0%').attr('stop-color', '#667eea');
    wordGradient.append('stop').attr('offset', '100%').attr('stop-color', '#764ba2');
    
    const rootGradient = defs.append('linearGradient')
      .attr('id', 'rootGradient')
      .attr('x1', '0%').attr('y1', '0%')
      .attr('x2', '100%').attr('y2', '100%');
    rootGradient.append('stop').attr('offset', '0%').attr('stop-color', '#f093fb');
    rootGradient.append('stop').attr('offset', '100%').attr('stop-color', '#f5576c');
    
    // Add glow filter
    const filter = defs.append('filter').attr('id', 'glow');
    filter.append('feGaussianBlur').attr('stdDeviation', '3').attr('result', 'coloredBlur');
    const feMerge = filter.append('feMerge');
    feMerge.append('feMergeNode').attr('in', 'coloredBlur');
    feMerge.append('feMergeNode').attr('in', 'SourceGraphic');
    
    const simulation = d3.forceSimulation(data.nodes)
      .force('link', d3.forceLink(data.links).id(d => d.id).distance(120))
      .force('charge', d3.forceManyBody().strength(-300))
      .force('center', d3.forceCenter(width / 2, height / 2))
      .force('collision', d3.forceCollide().radius(30));
    
    const link = g.append('g')
      .selectAll('line')
      .data(data.links)
      .enter().append('line')
      .attr('stroke', '#8e9aaf')
      .attr('stroke-width', 3)
      .attr('stroke-opacity', 0.6)
      .style('filter', 'drop-shadow(0 2px 4px rgba(0,0,0,0.1))');
    
    const node = g.append('g')
      .selectAll('circle')
      .data(data.nodes)
      .enter().append('circle')
      .attr('r', d => d.type === 'word' ? 12 : 10)
      .attr('fill', d => d.type === 'word' ? 'url(#wordGradient)' : 'url(#rootGradient)')
      .attr('stroke', '#ffffff')
      .attr('stroke-width', 2)
      .style('filter', 'url(#glow)')
      .style('cursor', 'pointer')
      .on('mouseover', function(event, d) {
        d3.select(this)
          .transition()
          .duration(200)
          .attr('r', d => d.type === 'word' ? 16 : 14)
          .attr('stroke-width', 3);
      })
      .on('mouseout', function(event, d) {
        d3.select(this)
          .transition()
          .duration(200)
          .attr('r', d => d.type === 'word' ? 12 : 10)
          .attr('stroke-width', 2);
      });
    
    const label = g.append('g')
      .selectAll('text')
      .data(data.nodes)
      .enter().append('text')
      .text(d => d.label)
      .attr('font-size', '13px')
      .attr('font-weight', '600')
      .attr('class', d => d.type === 'root' ? 'root-text' : 'word-text')
      .attr('text-anchor', 'middle')
      .attr('dy', -18)
      .attr('fill', '#2d3748')
      .style('text-shadow', '0 1px 2px rgba(255,255,255,0.8)')
      .style('pointer-events', 'none');
    
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

  // Enhanced graph visualization function
  function createEnrichedGraph(data) {
    const width = 800;
    const height = 600;
    
    const svg = d3.select('#graph-viz')
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .style('background', 'linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)')
      .style('border-radius', '12px');
    
    const defs = svg.append('defs');
    
    // Category colors
    const categoryColors = {
      'emotion': '#ff6b6b',
      'abstract_concept': '#4ecdc4', 
      'academic': '#45b7d1',
      'nature': '#96ceb4',
      'psychology': '#dda0dd',
      'default': '#95a5a6'
    };
    
    const g = svg.append('g');
    
    // Enhanced simulation
    const simulation = d3.forceSimulation(data.nodes)
      .force('link', d3.forceLink(data.edges).id(d => d.id).distance(120))
      .force('charge', d3.forceManyBody().strength(-400))
      .force('center', d3.forceCenter(width / 2, height / 2))
      .force('collision', d3.forceCollide().radius(30));
    
    // Links
    const link = g.append('g')
      .selectAll('line')
      .data(data.edges)
      .enter().append('line')
      .attr('stroke', '#999')
      .attr('stroke-width', 2);
    
    // Nodes with category-based colors
    const node = g.append('g')
      .selectAll('circle')
      .data(data.nodes)
      .enter().append('circle')
      .attr('r', d => {
        let baseRadius = d.type === 'EnglishWord' ? 15 : 12;
        if (d.properties?.frequency === 'very_high') baseRadius *= 1.4;
        else if (d.properties?.frequency === 'high') baseRadius *= 1.2;
        return baseRadius;
      })
      .attr('fill', d => {
        if (d.type === 'GreekRoot' && d.properties?.category) {
          return categoryColors[d.properties.category] || categoryColors.default;
        }
        return d.type === 'EnglishWord' ? '#2c5aa0' : categoryColors.default;
      })
      .attr('stroke', '#fff')
      .attr('stroke-width', 2)
      .style('cursor', 'pointer');
    
    // Labels
    const label = g.append('g')
      .selectAll('text')
      .data(data.nodes)
      .enter().append('text')
      .text(d => d.label)
      .attr('text-anchor', 'middle')
      .attr('dy', -20)
      .attr('font-size', '12px')
      .attr('fill', '#2d3748');
    
    // Simulation tick
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

<main>
  <div class="card">
    <h1>ῥίζα</h1>
    <p class="subtitle">Explore the Greek roots of the English language.</p>

    <div class="search-container">
      <input
        type="text"
        bind:value={wordToSearch}
        placeholder="Enter a word (e.g., philosophy)"
        on:keydown={(e) => e.key === 'Enter' && searchForRoot()}
      />
      <button class="search-btn" on:click={searchForRoot} disabled={isLoading}>
        {isLoading ? 'Searching...' : 'Search'}
      </button>
    </div>

    {#if searchResult && searchResult.roots.length > 0}
      <div class="result" transition:fade={{ duration: 600 }}>
        <h2>{searchResult.name}</h2>
        <ul>
          {#each searchResult.roots as root}
            <li class="root-item">
              <div class="root-main">
                <strong class="greek-text">{root.name}</strong> 
                <span class="root-transliteration">({root.transliteration})</span>:
                <span class="root-meaning">{root.meaning}</span>
              </div>
              {#if root.category || root.frequency || root.part_of_speech}
                <div class="root-details">
                  {#if root.category}
                    <span class="root-tag category">{root.category}</span>
                  {/if}
                  {#if root.frequency}
                    <span class="root-tag frequency">{root.frequency} frequency</span>
                  {/if}
                  {#if root.part_of_speech}
                    <span class="root-tag pos">{root.part_of_speech}</span>
                  {/if}
                </div>
              {/if}
            </li>
          {/each}
        </ul>
        {#if !showGraphViz}
          <button class="graph-btn" on:click={() => showGraph(searchResult.name)}>
            View Graph
          </button>
        {/if}
      </div>
    {:else if searchResult && searchResult.roots.length === 0}
      <div class="result no-roots" transition:fade={{ duration: 600 }}>
        <h2>{searchResult.name}</h2>
        <p class="no-roots-message">No Greek roots found for this word.</p>
      </div>
    {/if}

    {#if showGraphViz}
      <div class="graph-container" transition:slide={{ duration: 500 }} on:introend={() => document.querySelector('.graph-container').scrollIntoView({ behavior: 'smooth', block: 'start' })}>
        <h3>Etymology Graph</h3>
        <div id="graph-viz"></div>
        <button class="graph-btn" on:click={() => showGraphViz = false}>Close Graph</button>
      </div>
    {/if}

    {#if errorMessage}
        <p class="error">{errorMessage}</p>
    {/if}
  </div>
</main>