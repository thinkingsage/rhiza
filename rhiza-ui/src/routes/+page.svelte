<script>
  import { fade, slide } from 'svelte/transition';
  
  // This block contains our JavaScript logic
  let wordToSearch = '';
  let isLoading = false;
  let searchResult = null;
  let errorMessage = null;
  let showGraphViz = false;

  async function searchForRoot() {
    if (!wordToSearch.trim()) return;

    isLoading = true;
    searchResult = null;
    errorMessage = null;

    try {
      const response = await fetch(`http://localhost:8000/word/${wordToSearch.trim()}`);

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        const errorMsg = errorData.detail || `Server error (${response.status})`;
        throw new Error(errorMsg);
      }

      searchResult = await response.json();
    } catch (error) {
      errorMessage = error.message;
      console.error('Failed to fetch word roots:', error);
    } finally {
      isLoading = false;
    }
  }

  async function showGraph(word) {
    try {
      const response = await fetch(`http://localhost:8000/word/${word}/graph`);
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
    
    const width = 400;
    const height = 300;
    
    const svg = d3.select('#graph-viz')
      .append('svg')
      .attr('width', width)
      .attr('height', height);
    
    const simulation = d3.forceSimulation(data.nodes)
      .force('link', d3.forceLink(data.links).id(d => d.id).distance(80))
      .force('charge', d3.forceManyBody().strength(-200))
      .force('center', d3.forceCenter(width / 2, height / 2));
    
    const link = svg.append('g')
      .selectAll('line')
      .data(data.links)
      .enter().append('line')
      .attr('stroke', '#999')
      .attr('stroke-width', 2);
    
    const node = svg.append('g')
      .selectAll('circle')
      .data(data.nodes)
      .enter().append('circle')
      .attr('r', d => d.type === 'word' ? 8 : 6)
      .attr('fill', d => d.type === 'word' ? '#2c5aa0' : '#e74c3c');
    
    const label = svg.append('g')
      .selectAll('text')
      .data(data.nodes)
      .enter().append('text')
      .text(d => d.label)
      .attr('font-size', '12px')
      .attr('class', d => d.type === 'root' ? 'root-text' : 'word-text')
      .attr('text-anchor', 'middle')
      .attr('dy', -10);
    
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
            <li>
              <strong class="greek-text">{root.name}</strong> 
              <span class="root-transliteration">({root.transliteration})</span>:
              <span>{root.meaning}</span>
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