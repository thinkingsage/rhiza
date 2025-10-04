<script>
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
        throw new Error(`An error occurred: ${response.statusText}`);
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
      <div class="result">
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
    {/if}

    {#if showGraphViz}
      <div class="graph-container">
        <h3>Etymology Graph</h3>
        <div id="graph-viz"></div>
        <button on:click={() => showGraphViz = false}>Close Graph</button>
      </div>
    {/if}

    {#if errorMessage}
        <p class="error">{errorMessage}</p>
    {/if}
  </div>
</main>

<style>
  main {
    font-family: var(--font-sans);
    display: flex;
    justify-content: center;
    align-items: flex-start;
    padding-top: 5rem;
    min-height: 100vh;
    background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
    background-attachment: fixed;
  }

  .card {
    background: linear-gradient(145deg, #ffffff 0%, #fefefe 100%);
    padding: 2.5rem;
    border-radius: 16px;
    box-shadow: 
      0 10px 25px rgba(0, 0, 0, 0.1),
      0 4px 10px rgba(0, 0, 0, 0.05),
      inset 0 1px 0 rgba(255, 255, 255, 0.9);
    width: 100%;
    max-width: 500px;
    text-align: center;
    border: 1px solid rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(10px);
  }

  h1 {
    font-family: var(--font-serif);
    color: #333;
    font-weight: 600;
    font-size: 2.5rem;
  }

  p {
    color: #666;
    margin-bottom: 2rem;
  }

  .search-container {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 1.5rem;
  }

  input {
    flex-grow: 1;
    padding: 0.75rem;
    border: 1px solid #ccc;
    border-radius: 5px;
    font-size: 1rem;
    font-family: var(--font-sans);
  }

  button:disabled {
    background-color: #aaa;
    cursor: not-allowed;
  }
  
  .result {
    text-align: left;
    margin-top: 2rem;
  }

  .result h2 {
    font-family: var(--font-serif);
    text-transform: capitalize;
  }

  .result ul {
    list-style-type: none;
    padding: 0;
  }

  .result li {
    background-color: #f9f9f9;
    padding: 0.75rem;
    border: 1px solid #eee;
    border-radius: 5px;
    margin-bottom: 0.5rem;
  }

  .result li strong {
    font-family: var(--font-serif);
    font-style: italic;
    font-size: 1.1em;
  }
  
  .error {
    color: #d93025;
    margin-top: 1rem;
  }
</style>